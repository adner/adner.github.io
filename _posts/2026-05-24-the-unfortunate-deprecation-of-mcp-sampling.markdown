---
layout: post
title:  "The new MCP spec and the unfortunate deprecation of MCP Sampling"
date:   2026-05-25
image: /images/260525/splash.png
permalink: /new-mcp-spec.html
---
{% if page.image %}
  <a href="{{ page.url | relative_url }}">
    <img src="{{ page.image | relative_url }}" alt="{{ page.title }}">
  </a>
{% endif %}

Greetings from beautiful Portorož in Slovenia, where I am joining [Jonas Rapp](https://www.linkedin.com/in/rappen/) to present a session titled *"How and why did we implement AI Chat in FetchXML Builder?"* at the [DynamicsMinds](https://www.dynamicsminds.com/) conference. We are talking about our fun collaboration from last year, where we added AI chatbot functionality to Jonas' tool *FetchXML Builder* - one of the most widely used Power Platform community tools (even mentioned in the [official docs](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/fetchxml/overview#community-tools)!). <!--end_excerpt-->

This was a fun project, since it was an "infusion of AI" into an existing codebase, running on "legacy" technology (.NET Framework), rather than the greenfield AI projects I usually do. You can read more about my contribution in my blog post [*The anatomy of FetchXML Builder with AI*](https://nullpointer.se/2025/07/29/fetchxmlbuilder-ai-anatomy.html) from last summer.

So, if you are at DynamicsMinds, please come by and say hi!

But now, let's put fun conferences aside, and get back to talking about AI protocols.

## New MCP specification!
The MCP specification is evolving, and a release candidate for the next version of the spec (2026-07-28) was [announced](https://blog.modelcontextprotocol.io/posts/2026-07-28-release-candidate/) a couple of days ago by [Den Delimarsky](https://www.linkedin.com/in/dendeli) (former Microsoft, now working with MCP at Anthropic) and [David Soria Parra](https://www.linkedin.com/in/david-soria-parra-4a78b3a/) (part of the Technical Staff at Anthropic). It is said to be "the largest revision of the protocol since launch", and it comes with a few goodies:

- **Stateless core** - No more initialization handshakes or session IDs, which helps with load balancers, etc.

- **MCP Apps ships as an official extension** - Great news, since MCP Apps is by far one of the most exciting parts of the MCP spec, and something that I have written about extensively lately, for example:
    - A [demo](https://www.linkedin.com/posts/andreasadner_powerapps-microsoftcopilot-ugcPost-7448665788577832960-DmA-) of how to use MCP Apps UI components in Microsoft 365 Copilot.
    - A [demo](https://www.linkedin.com/posts/andreasadner_microsoftcopilot-ugcPost-7455742575875031041-78Xy) of how to embed Claude Code in a terminal, as an MCP Apps agent in M365 Copilot.
    - A [demo](https://www.linkedin.com/posts/andreasadner_microsoftcopilot-dataverse-activity-7462177225937887232-zR5Q) of how to use [Jukka Niiranen's](https://www.linkedin.com/in/jukkaniiranen/) [Dataverse Capacity MCP Server](https://licensing.guide/licensing-knowledge-for-ai-agents-dataverse-capacity-mcp-server/) from an M365 Copilot agent, with custom UI powered by MCP Apps.

...among many other changes. They are also introducing a *[Feature Lifecycle Policy](https://github.com/modelcontextprotocol/modelcontextprotocol/pull/2596)* for MCP features, which allows the maintainers of the MCP spec to formalize the lifecycle around MCP features - that can now be ***Active***, ***Deprecated*** and ***Removed***. A change in the lifecycle status of a feature comes with a 12-month window between deprecation and removal, to allow consumers to adapt. This is a good thing, I guess...

## The missed opportunity of the MCP Sampling feature

What is not so good is that they are also deprecating what is probably my favourite feature in the MCP Spec (well, except for MCP Apps, of course) - [MCP Sampling](https://modelcontextprotocol.io/specification/2025-11-25/client/sampling).

Despite its name, *MCP Sampling* has nothing to do with music - it is a way for MCP Server tools to "piggy back" on the MCP Client's Large Language Model, and use that LLM for completions. In the words of the specification:

```text
The Model Context Protocol (MCP) provides a standardized way for servers to request LLM sampling (“completions” or “generations”) from language models via clients. This flow allows clients to maintain control over model access, selection, and permissions while enabling servers to leverage AI capabilities—with no server API keys necessary. Servers can request text, audio, or image-based interactions and optionally include context from MCP servers in their prompts.
```
So, this basically gives the MCP Server tool access to its own LLM (borrowed from the client), and it requires no AI plumbing on the MCP Server side, and no API key - the MCP Client pays for the inference! 

I have blogged and posted about this feature extensively for the last year, and explored it in various ways:

- In [this blog post](https://nullpointer.se/2025/08/21/mcp-automatic-report-generation.html) I use MCP Sampling to allow an MCP tool to dynamically generate reports, based on user input. 

- In my [LinkedIn post](https://www.linkedin.com/posts/andreasadner_mcp-vscode-activity-7444081850974879745-PTE-) "What if your MCP Server could think for itself?" I explore a related MCP feature - [SEP-1577 Sampling with Tools](https://modelcontextprotocol.io/seps/1577--sampling-with-tools) - a feature that made the Sampling capability even more powerful, by allowing LLM calls made by the tool through Sampling to also be able to call other MCP Server tools. 

This could have been a real game-changer, since with the "Sampling with tools" feature the MCP Server could take over the steering-wheel and drive its own agentic loop, all on its own, using the client's model. This inverts the typical MCP control flow: instead of the client orchestrating everything, the *tool itself* becomes an agent orchestrator - able to reason, call other MCP tools and iterate until it arrives at an answer. All while borrowing the client's LLM, and on the client's dime.

Think about what that unlocks. For example, a `research_topic` tool no longer has to return a single canned answer - it can fan out across a dozen searches, read and summarize the results, follow the promising threads, and synthesize a final report before handing anything back. A `fix_bug` tool can plan an approach, edit a file, run the tests, observe the failure, and try again. A domain-expert MCP Server - say, one that knows everything there is to know about Dataverse, FetchXML, or Power Platform licensing - can host a full agent loop *server-side*, but the user still gets to pick *which* model powers it and *who* pays for the tokens.

This is all really sad - it sure feels like a lost opportunity to make MCP Servers more intelligent, autonomous and agentic. 

So why is it deprecated? [**SEP-2577: Deprecate Roots, Sampling, and Logging**](https://github.com/modelcontextprotocol/modelcontextprotocol/pull/2577) gives some answers. They list a couple of reasons for the coming death of Sampling:

- Low adoption - Yes, that is true, sort of - and maybe not as true as it used to be. VS Code has had [good, although experimental support](https://code.visualstudio.com/updates/v1_101#_mcp-support-for-sampling-experimental) for Sampling for a long time, and I have done all my experiments there. But looking at the official list of [supported MCP Clients](https://modelcontextprotocol.io/clients), that list is actually pretty long, nowadays.

- Complex to implement - Perhaps true, but hasn't stopped many clients from shipping it.

The deprecation wasn't without debate, as can be seen from the comments to [SEP-2577](https://github.com/modelcontextprotocol/modelcontextprotocol/pull/2577), but I am not really seeing anyone mentioning the main benefit that I see with sampling, and that I mention above - all the agentic capabilities it opens up.

Even though the new MCP Spec is not set in stone, I am assuming this will be the death of MCP Sampling. So long old friend, it has been a fun ride and I hate to see you go.

The silver lining? Thanks to that brand new *Feature Lifecycle Policy*, MCP Sampling won't actually disappear for at least 12 months after the deprecating spec ships - so if you have never built an MCP Server that uses Sampling, now is the time to give it a try. Go grab some inference tokens on the client's tab while you still can!

Until next time, happy hacking!
