---
layout: post
title:  "Declarative Agents with Work IQ MCP Servers"
date:   2026-04-06
image: /images/260406/splash.png
permalink: /declarative-agents-workiq.html
---
{% if page.image %}
  <a href="{{ page.url | relative_url }}">
    <img src="{{ page.image | relative_url }}" alt="{{ page.title }}">
  </a>
{% endif %}

It has been a while since I last looked into [Agent 365 SDK](https://learn.microsoft.com/en-us/microsoft-agent-365/overview), and since then a couple of interesting things have happened. <!--end_excerpt--> 

First of all, a release date has been announced for [Microsoft 365 E7](https://partner.microsoft.com/en-US/blog/article/agent-365-announcement), a new type of license that includes Agent 365 capabilities. It is worth noting that the parts of Agent 365 that have to do with agentic identities and autonomous agentic users will not be GA on 1st of May, and licensing details regarding this are yet to be announced. This is a bit of a bummer, since I have spent a lot of time the last few months exploring the agentic parts of Agent 365 (see for example [here](https://nullpointer.se/exploring-agent-365-cli.html) and [here](https://nullpointer.se/agent-365-notifications.html)), and it would have been cool to be able to test it in production. But for the time being, agentic users are kept in the [Frontier program](https://www.microsoft.com/en-us/microsoft-365-copilot/frontier-program) and we'll have to wait a bit longer until it becomes generally available.

The parts of Agent 365 that go GA in May are all about agents acting "on-behalf-of" the user. Check out [this](https://www.youtube.com/watch?v=Mszz9ntbVpc) Agent 365 AMA for a deep-dive on this topic.

Another thing that has happened is that the ***Agent 365 tooling servers*** have been rebranded to [Work IQ MCP](https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview). [This](https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview) is how Work IQ is described by Microsoft:

*"Work IQ is the intelligence layer that grounds Microsoft 365 Copilot and your agents in real-time, shared context across your organization."*

So from a product/marketing perspective I guess it makes sense to "move" the MCP Servers from Agent 365 to Work IQ, as it positions Agent 365 as being all about agent governance, while Work IQ deals with the data.

### The Work IQ MCP Servers

Since Ignite 2025 I have done a lot of demos and blog posts about the Agent 365 MCP servers (now called Work IQ MCP), for example:

- Two blog posts describing how to use the MCP Servers from a custom agent - [part 1](https://nullpointer.se/agent-365-mcp-servers-part-1.html) and [part 2](https://nullpointer.se/agent-365-mcp-servers-part-1.html).

- A [post](https://nullpointer.se/exploring-agent-365-cli.html) about how to use an (at that time) undocumented feature for creating custom MCP Servers in Agent 365.

- A [post](https://nullpointer.se/agent-365-notifications.html) about how to let an agent respond to Word comments and send emails using the Agent 365 notification functionality.

Lately, it seems that these MCP servers have gotten much easier to access and to use, something that I explored in a [recent LinkedIn post](https://www.linkedin.com/posts/andreasadner_workiq-agent365-activity-7445431916155240448-UByj?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) where I tried out the servers from VS Code.

Lately, it has really felt like the tooling is starting to come together, and the Work IQ MCP Servers have pretty much everything we need to do work in Microsoft 365 work from an agent. Exciting times, for sure!

The Work IQ MCP Servers are still [documented](https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview) as part of the Agent 365 docs. At the time of writing, these are the available MCP Servers:

- Work IQ Copilot
- Work IQ User
- Work IQ Mail
- Work IQ Calendar
- Work IQ Teams
- Work IQ Word
- Work IQ OneDrive 
- Work IQ SharePoint
- Dataverse MCP Server
- Microsoft MCP management MCP server

When it comes to data retrieval, the **Work IQ Copilot** MCP Server is the "swiss army knife" that allows for retrieval of pretty much all your M365 data. It has only one tool - **copilot_chat** - and the description is pretty telling:

```text
Use this tool for any user request that might require finding, searching, discovering, or locating information contained within Microsoft 365 content—including documents, PDFs, spreadsheets, emails, sites, reports, or files—regardless of whether the question appears general or domain-specific.

If the user's request could plausibly be answered using organizational content, you must invoke this tool unless a workload-specific tool exists for that scenario. When no dedicated tool (mail, calendar, Teams, OneDrive, SharePoint, etc.) is available, this tool becomes the primary mechanism for retrieval.

If the request mentions a specific workload and its tool is unavailable, you might use this search tool as a fallback. If the search tool can't retrieve the information, clearly state that the information isn't accessible from the available tools instead of answering from general knowledge.
```

So this truly is (or should be) the "one MCP Server to rule them all", at least when it comes to data retrieval. When it comes to *updating* data it is a different story, and that is what the rest of the MCP Servers are for. More on that later.

### So much cool stuff from Redmond
Just the last couple of weeks so much cool stuff has come out from Microsoft, that it has honestly been hard to keep up. If you follow me on LinkedIn, you probably know that I have spent a lot of time the last six months exploring various specifications for agentic user interfaces, such as [AG-UI](https://docs.ag-ui.com/), [A2UI](https://a2ui.org/) and [MCP Apps](https://modelcontextprotocol.io/extensions/apps/overview). Lately, it has been really exciting to see these specs have finally made their way into the Microsoft ecosystem:

- On 9th of March it was [announced](https://techcommunity.microsoft.com/blog/microsoft365copilotblog/enable-agents-to-bring-apps-into-the-flow-of-work%E2%80%94while-keeping-it-in-control/4499464) that MCP Apps and OpenAI Apps SDK would be available for [Copilot declarative agents](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/declarative-agent-ui-widgets). I posted a [video to LinkedIn](https://www.linkedin.com/posts/andreasadner_copilot-mcp-activity-7441598020539908097-_JA6) where I ran Doom in a Copilot agent, by serving it as a OpenAI Apps SDK resource from an MCP Server.

- Then it was [announced](https://learn.microsoft.com/en-us/power-apps/maker/model-driven-apps/customize-microsoft-365-copilot-chat) that a custom Copilot agent could be used from a model-driven Power App, which I also [tried out](https://www.linkedin.com/posts/andreasadner_microsoftcopilot-activity-7444647079043289089-HcpT).

- And if that was not enough, it was [announced](https://www.microsoft.com/en-us/power-platform/blog/power-apps/public-preview-your-business-apps-now-part-of-every-conversation/) that a model-driven Power App could be exposed as an MCP Server that could be used from a [declarative Copilot agent](https://learn.microsoft.com/en-us/power-apps/maker/model-driven-apps/app-properties#steps-to-set-up-power-apps-in-copilot) - and that also served some custom UIs! I created a [demo of this](https://www.linkedin.com/posts/andreasadner_dataverse-powerapps-microsoftcopilot-activity-7445817384805916672-E9Ue) also.

It seems that lately all this awesomeness has come to [Copilot Declarative agents](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/overview-declarative-agent). And the single thing that enables all of the coolness is the ability to [use MCP Servers](https://learn.microsoft.com/sv-se/microsoft-365/copilot/extensibility/build-mcp-plugins) from a declarative agent.

What is a declarative agent? Well, basically it is a no-code agent that can be put together *declaratively* (through lots of bundled files that describe the agent capabilities). A suggested way of doing this is to use the [Microsoft 365 Agents Toolkit](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/overview-agents-toolkit?toc=%2Fmicrosoftteams%2Fplatform%2Ftoc.json&bc=%2Fmicrosoftteams%2Fplatform%2Fbreadcrumb%2Ftoc.json), a VS Code extension that makes it possible to create such agents in a simple way.

So, since it is possible to use MCP Servers from a declarative agent, then we must of course try to use the Work IQ MCP Servers from a declarative agent! 

### Using Work IQ MCP servers from a Microsoft 365 Copilot declarative agent
First of all, we need a way of finding out the metadata for the Work IQ MCP Servers, so we can add them to our declarative agent. Haven't found this in the docs yet, but deeply hidden in this [PR](https://github.com/microsoft/work-iq/pull/81/changes#diff-2751ce6cddba440258973781929f26eb1e448020009dc6573318781aac7afba9) we can find a file that contains URLs to the various Work IQ MCP Servers. Example:

```json
  "WorkIQ-Me-MCP-Server": {
      "url": "https://agent365.svc.cloud.microsoft/agents/tenants/<TENANT_ID>/servers/mcp_MeServer",
      "type": "http"
      ...
    }
```

Replace `<TENANT_ID>` with your own tenant ID, and you have the MCP Server URL.

So, now that we have the MCP Server URLs, let's try to add them to a declarative agent, using the **Microsoft 365 Agents Toolkit** extension in VS Code. Install the extension, click the "M365" button and hit "Create a new agent/app":

![alt text](/images/260406/image.png)

Then, select "Declarative agent" -> "Add an action" -> "Start with an MCP Server", and then add the URL to the MCP Server. This scaffolds the declarative agent project, and adds your MCP Server to the `mcp.json` file:

![alt text](/images/260406/image-1.png)

Click "Start" to start the MCP Server. After authenticating, you can see that the MCP Server is connected and the tools (5 in this case) are loaded:

![alt text](/images/260406/image-2.png)

Then, click "ATK: Fetch action from MCP" to add the MCP Server tools to the `ai-plugin.json` file. Select all tools that you want to add:

![alt text](/images/260406/image-3.png)

For auth, select "OAuth (with static registration)":

![alt text](/images/260406/image-4.png)

You will see an error message saying `Unable to find the authentication metadata in the MCP server. ` which can be disregarded. The Work IQ MCP Servers unfortunately don't publish authorization config information as they should, so we will add this info manually later.

Now two things have happened:

-  `ai-plugin.json` has been updated with descriptions for all the tools that are exposed by the added MCP Server.
-  `m365agents.yml` has been updated with infra provisioning information.

Now it is time to add the missing authorization information to the `m365agents.yml` file. Add the following rows:

![alt text](/images/260406/image-5.png)

**Make sure to replace the GUID:s with your Tenant ID!**

Next, we need to setup the infra necessary to make it possible to do OAuth2 authentication with the MCP Servers. How to accomplish this for declarative agent MCP plugins is described [here](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/api-plugin-authentication) in the docs.

First, we need to add an App Registration to Entra ID. Create the app registration and:

- Create a **web** redirect URL that points to: `https://teams.microsoft.com/api/platform/v1.0/oAuthRedirect`

- Make a note of the app registration ID.

- Create an app registration secret and make a note of it.

Then, add API permissions for the Work IQ MCP Servers that you intend to use in your declarative agent, and grant admin consent for these.:

![alt text](/images/260406/image-6.png)

Back in VS Code, click "Provision" in the "M365 Agents Toolkit" pane:

![alt text](/images/260406/image-7.png)

In the dialogs that are shown, enter:

- The ID for the application registration that you created earlier.

- The Client Secret that you created earlier.

- The MCP Server scope (same as you added to the `m365agents.yml` file, for example `https://agent365.svc.cloud.microsoft/agents/tenants/<YOUR TENANT ID>/servers/mcp_MeServer/.default`)

Now M365 Agent Toolkit will create the infra for your agent, and when completed you can find the agent in the Teams Dev Portal: [https://dev.teams.microsoft.com/](https://dev.teams.microsoft.com/). There, you can also see that OAuth client registrations have been created for all the MCP Servers that you added. This allows you to authenticate against the Work IQ MCP Servers when using the agent:

![alt text](/images/260406/image-8.png)

You can now try your agent by opening it up in the Teams Dev Portal, and clicking "Preview in Teams":

![alt text](/images/260406/image-9.png)

You should now have a working declarative agent that uses the Work IQ MCP Servers! 

In the video below I have wired up the agent with the `mcp_MeServer`, `mcp_CalendarTools`, `mcp_MailTools` and `mcp_M365Copilot` Work IQ MCP Servers. 

This has been fun, declarative agents and Work IQ MCP Servers are pretty awesome. Until next time, happy hacking!

<iframe width="560" height="315" src="https://www.youtube.com/embed/AdhkoSNJPvk?si=22RUVRK0AGuaOwAZ" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>






