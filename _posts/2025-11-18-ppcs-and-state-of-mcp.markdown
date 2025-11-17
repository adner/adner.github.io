---
layout: post
title:  "The PPCS agent, dynamic C# code generation and the state of MCP"
date:   2025-11-17
image: /images/251117/splash.png
permalink: /ppcs-and-state-of-mcp.html
---
{% if page.image %}
  <a href="{{ page.url | relative_url }}">
    <img src="{{ page.image | relative_url }}" alt="{{ page.title }}">
  </a>
{% endif %}

Last week was really fun, I had the privilege of presenting at the [Power Platform Community Sweden (PPCS)](https://powerplatformsweden.se/) event in Stockholm on the 12th of November, and I took the chance to discuss some topics that have interested me over the last couple of months - the [Microsoft 365 Agent SDK](https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/), the [Teams AI SDK](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/welcome) and the [Microsoft Agent SDK](https://learn.microsoft.com/en-us/agent-framework/overview/agent-framework-overview) - as well as a few words about AI architecture. 

<!--end_excerpt-->

[Sara Lagerquist](https://www.linkedin.com/in/saralagerquist/) is the driving force behind the Power Platform Community in Sweden, and it really is an amazing community that she has created, with so many nice people and an amazing vibe overall. 14-time MVP [Gustaf Westerlund](https://www.linkedin.com/in/gustafwesterlund/) held a great presentation about Principal Object Access (POA), a veeery techical topic that he still managed to make very entertaining and fun!
 
In my presentation I showed a lot of demos (videos - doing live-demos is scary), basically a "best of" what I have posted to LinkedIn in the last couple of months. If you are interested, here is a "supercut" containing all the demos that I showed at the event:

<iframe width="560" height="315" src="https://www.youtube.com/embed/GJLqc2VH9CA?si=DBsFGrOUnNiiEM5C" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

One of the main themes of the presentation was the creation of the "Power Platform Community Sweden" agent - a chatbot that could help Sara plan events, using a lot of different channels - like Claude Desktop, Teams, Copilot and a custom web app. I created an MCP Server for this purpose, that had a couple of simple tools that the agent can use:

- CreateEvent 
- CreateSpeaker
- AddSpeakerToEvent
- ExecuteFetch - for querying Dataverse using FetchXml.

In the first demo I showed this MCP Server used from Claude Desktop, using the list of past events and speakers from the [PPCS website](https://powerplatformsweden.se/) and adding them to the database using MCP. The code for the MCP Server can be found in [this repo](https://github.com/adner/PPCS_251112/tree/main/PPCS_MCP). The demo looked like this:
 
<iframe width="560" height="315" src="https://www.youtube.com/embed/aRRVufV1UMw?si=ZtLRllMFHgbi66dK" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

Good thing it was a pre-recorded video that could be sped up, for the process of creating the events and speakers was painfully slow - it took almost eight minutes to create everything, and Claude Desktop was getting more and more sluggish as it went along, eventually almost grinding to a complete halt. Apparently, the really simple process of enumerating ~20 events and ~40 speakers and adding them to Dataverse in a loop, one at a time, using an MCP tool is real hard work for Claude. Why is that?

Perhaps this [article from Anthropic](https://www.anthropic.com/engineering/code-execution-with-mcp) sheds some light on this issue, and if you are into internet flamewars [this YouTube video](https://www.youtube.com/watch?v=1piFEKA9XL0) is also worth a watch. 

With MCP gaining a lot of popularity, agents often have quite a lot of MCP Servers connected to them, and the tool definitions get added to the context, potentially eating up so much context that the model spends more time parsing and interpreting tool metadata than actually solving the task at hand. And the results of tool calls, which may be large, also gets added to the context – and the result is a sluggish, barely usable agent. This sounds exactly like what happened in my demo: each individual MCP call was simple, but the cumulative overhead grew with every tool call, eventually overwhelming the context window. Not good, not good at all. Is there a better option?

The article outlines an interesting idea – instead of letting the LLM perform repeated MCP tool calls, instead let the LLM dynamically write code that executes the tool calls. That way, the tool definitions and tool call results are kept out of the context window. Pure genius! But does it work? 

I wanted to try it out for myself, so I [rewrote the PPCS MCP Server](https://github.com/adner/McpCodeGenTest/tree/main/PPCS_MCP) from my demo and modified it so that it only has one tool - `RunScript` - that can be used to run C# code that has been dynamically generated by the LLM. The `ScriptRunnerLib` contains a [small library](https://github.com/adner/McpCodeGenTest/blob/main/ScriptRunnerLib/ScriptRunnerLib.cs) that makes it possible to execute this code at runtime. The secret sauce here is the [Roslyn](https://github.com/dotnet/roslyn/) C# Scripting SDK, such a cool library!

So, I hooked up the new and improved MCP Server to Claude and the results were actually quite amazing! Instead of 8 minutes, it took only 41 seconds to add all events and speakers:

<iframe width="560" height="315" src="https://www.youtube.com/embed/44vCppI1brI?si=A3jzT1pRLdSet1sD" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

To make sure that the agent generated C# code that plays well with the Roslyn C# compiler, I gave it [very detailed (and verbose) instructions](https://github.com/adner/McpCodeGenTest/blob/main/AgentSDK/agent_instructions_codegen.md) - a couple of thousand tokens worth. 

The execution in Claude Desktop was much faster, to be sure, but how can we know that it actually consumes less tokens? Claude Desktop doesn't tell me the amount of tokens, so we'll have to try it out in a different way. So, I went ahead and created two agents using the [Microsoft Agent Framework](https://github.com/microsoft/agent-framework), one agent that calls the tools one by one, MCP-style, and one that generates code instead. The code can be found [here](https://github.com/adner/McpCodeGenTest/tree/main/AgentSDK).

We give the agents the following prompt, and then feed it a [text file with all the speakers and events](https://github.com/adner/McpCodeGenTest/blob/main/AgentSDK/past_events.txt):

```text
Please go through these past events and create the Events and Speakers in Dataverse. When done with all, just say 'Done!
```
Let's run both agents!

```csharp
Running tool calling agent...
- Tool Call: 'CreateEvent' (Args: [eventName = MALMÖ, Fellowmind],[location = MALMÖ],[eventDate = 2025-09-25T00:00:00Z]
- Tool Call: 'CreateSpeaker' (Args: [firstname = Danijel],[lastname = Buljat]
- Tool Call: 'CreateSpeaker' (Args: [firstname = David],[lastname = Schützer]
- Tool Call: 'CreateEvent' (Args: [eventName = STOCKHOLM, Xlent],[location = STOCKHOLM],[eventDate = 2025-09-03T00:00:00Z]
- Tool Call: 'CreateSpeaker' (Args: [firstname = Marica],[lastname = Lagerheim]
...
- Tool Call: 'CreateSpeaker' (Args: [firstname = Mark],[lastname = Smith]
- Tool Call: 'CreateSpeaker' (Args: [firstname = Chris],[lastname = Huntingford]
Done!

- Input Tokens (Streaming): 5584
- Output Tokens (Streaming): 1911 (0 was used for reasoning)
- Total tokens (Streaming): 7495
Tool Calling Agent Elapsed Time: 34313ms (34,31s)

Running code gen agent...
- Tool Call: 'RunScript' (Args: [code = using System;
using System.Collections.Generic;

// Helper to create a speaker and collect result
string CreateSpeakerSafe(string first, string last)
{
    var res = CreateSpeaker(first, last);
    return $"Speaker {first} {last}: {res}";
}

// Helper to create an event and collect result
string CreateEventSafe(string name, string location, DateTime date)
{
    var res = CreateEvent(name, location, date);
    return $"Event {name} ({location}, {date:yyyy-MM-dd}): {res}";
}

var results = new List<string>();

// 2025-09-25 MALMÖ, Fellowmind
results.Add(CreateEventSafe("Fellowmind", "Malmö", new DateTime(2025, 9, 25)));
results.Add(CreateSpeakerSafe("Danijel", "Buljat"));
results.Add(CreateSpeakerSafe("David", "Schützer"));

...

// 2019-09-05, Claremont
results.Add(CreateEventSafe("Claremont", "", new DateTime(2019, 9, 5)));
results.Add(CreateSpeakerSafe("Mark", "Smith"));
results.Add(CreateSpeakerSafe("Chris", "Huntingford"));

// Return all results so the host can see what happened
results]
Done!

- Input Tokens (Streaming): 8902
- Output Tokens (Streaming): 2186 (0 was used for reasoning)
- Total tokens (Streaming): 11088
Code Gen Agent Elapsed Time: 59346ms (59,35s)
```
Hmm, the tool calling agent took 34 seconds, and it consumed 7495 tokens. And the code-gen agent took 59 seconds and consumed 11088 tokens. Wait, what!? Why is the code-gen agent consuming more tokens, I thought MCP (tool-calling) was bad??

Actually, the LLM (GPT-5.1 in this case) is actually super smart. What actually seems to happen here is that the LLM does **parallel tool calling** and lets the client do all tool calls without passing the results back to the LLM! It is smart enough to figure out that the tool calls are actually "fire-and-forget" and it doesn't have to act on the results! Kind of clever! It seems that GPT-5.1 is doing a much better job than Claude Desktop for this particular scenario.

So, what happens if we give the LLM explicit instructions to actually evaluate the result from all tool calls? Let's change the prompt accordingly:

```text
Please go through these past events and create the Events and Speakers in Dataverse. After creating each Event or Speaker, make sure that it returns 'OK', before continuing to the next one. When done with all, just say 'Done!'
```
Let's run it again!

```csharp
Running tool calling agent...
- Tool Call: 'CreateSpeaker' (Args: [firstname = Danijel],[lastname = Buljat]
- Tool Call: 'CreateSpeaker' (Args: [firstname = David],[lastname = Schützer]
...
- Tool Call: 'CreateEvent' (Args: [eventName = Sopra Steria],[location = STOCKHOLM],[eventDate = 2023-05-10T00:00:00]
- Tool Call: 'CreateSpeaker' (Args: [firstname = Brian],[lastname = Stokes och Sara Lagerquist]

- Input Tokens (Streaming): 73907
- Output Tokens (Streaming): 1281 (0 was used for reasoning)
- Total tokens (Streaming): 75188
Tool Calling Agent Elapsed Time: 50376ms (50,38s)

Running code gen agent...
- Tool Call: 'RunScript' (Args: [code = using System;
using System.Collections.Generic;

string CreateSpeakerSafe(string first, string last)
{
    var res = CreateSpeaker(first, last);
    if (res != "OK") throw new Exception($"Failed to create speaker {first} {last}: {res}");
    return res;
}

string CreateEventSafe(string name, string location, DateTime date)
{
    var res = CreateEvent(name, location, date);
    if (res != "OK") throw new Exception($"Failed to create event {name}: {res}");
    return res;
}

// Helper to split full name into first/last (last word = last name)
(string first, string last) SplitName(string full)
{
    var parts = full.Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries);
    if (parts.Length == 1) return (parts[0], "");
    var last = parts[^1];
    var first = string.Join(" ", parts[..^1]);
    return (first, last);
}

void EnsureSpeakers(IEnumerable<string> speakers)
{
    foreach (var full in speakers)
    {
        if (string.IsNullOrWhiteSpace(full)) continue;
        var (first, last) = SplitName(full);
        CreateSpeakerSafe(first, last);
    }
}

// 2025-09-25 MALMÖ, Fellowmind
CreateEventSafe("2025-09-25 Fellowmind", "MALMÖ", new DateTime(2025,9,25));
EnsureSpeakers(new[]{"Danijel Buljat","David Schützer"});

...

// 2019-09-05, Claremont
CreateEventSafe("2019-09-05 Claremont", "", new DateTime(2019,9,5));
EnsureSpeakers(new[]{"Mark Smith","Chris Huntingford"});

return "Done!";]
Done!

- Input Tokens (Streaming): 5795
- Output Tokens (Streaming): 1990 (0 was used for reasoning)
- Total tokens (Streaming): 7785
Code Gen Agent Elapsed Time: 48390ms (48,39s)
```
Now the tool calling agent consumes 73907 tokens! And the code-gen agent consumes 7785 tokens. That is 90% tokens saved!!! 

So, is this the death of MCP? Well, I really don't think so and I think there are many ways of evolving the specification that could address the current issues. For example making batch operations a part of the specification, and ways of doing tool calls that are excluded from to the context. 

And perhaps most important - making it possible to pass results between tool calls without polluting the context. I have the feeling that existing primitives in the MCP specification - especially Resources - have a role to play here. Imagine if an LLM could pass MCP Resource Links as parameters to subsequent tool calls, that would make parameter passing really light-weight!

So, MCP is probably not dead but it could use some new features to handle these kind of scenarios better. 

Anyways, this was a fun experiment and I learned a thing or two about tool calling and context windows. As always, thanks for reading! The code for the examples above can be found [here](https://github.com/adner/McpCodeGenTest).  Happy hacking!



