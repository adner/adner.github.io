---
layout: post
title:  "The death of BizApps and the rise of the agentic Power Platform"
date:   2026-05-03
image: /images/260503/splash.png
permalink: /agentification-power-platform.html
---
{% if page.image %}
  <a href="{{ page.url | relative_url }}">
    <img src="{{ page.image | relative_url }}" alt="{{ page.title }}">
  </a>
{% endif %}

Sometime last summer, it started to dawn on me that business applications as we know them might soon be a thing of the past. 

I had been experimenting with the Model Context Protocol for a while, building custom agents that read and wrote to Dataverse directly - no UI in between. Talking to my business application in natural language, with MCP doing the plumbing, was unexpectedly delightful - and surprisingly productive. <!--end_excerpt-->If you are interested, you can find some of my early experiments with Dataverse and MCP [here](https://www.linkedin.com/posts/andreasadner_mvp-agenticai-powerplatform-activity-7318953890094235650-vLf9) and [here](https://www.linkedin.com/posts/andreasadner_agenticai-mcp-dataverse-activity-7319027765075165185-10Z5).

It was early days, before the release of the official [Dataverse MCP Server](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-mcp) - so I had to [roll my own](https://github.com/adner/SimpleDataverseMcpServer) - which turned out the be surprisingly easy, especially given the fact that LLMs are really good at FetchXML 😊.

Accessing Dataverse from an agent in this way was fun and all, but it became pretty clear that text might not be the optimal modality for using business applications, mainly because it is painfully slow (local Speech-to-text helps somewhat, see this [demo](https://www.linkedin.com/posts/andreasadner_building-my-own-crm-in-vs-code-using-mcp-activity-7427324074483302400-F52e)). This got me thinking - what if the agent could surface user interfaces when the user needs them - in addition to text?

Once again, it was early days and there wasn't much available in terms of standards or specifications for agentic user interfaces. [AG-UI](https://docs.ag-ui.com/introduction), [OpenAI Apps SDK](https://developers.openai.com/apps-sdk) and [MCP Apps](https://modelcontextprotocol.io/extensions/apps/overview), all of which I'd later spend a lot of time exploring, hadn't been announced yet. So, lacking official specs and tooling, I started rolling my own agent UIs.

Nowhere near enterprise-ready, but during this time I built a few demos that explored these ideas. [One of them](https://www.youtube.com/watch?v=k5Tc3AsMBls) showed a bespoke agent UI that pulled in Power Apps screens when needed, and rendered reports dynamically from natural language:

![](/images/260503/1.gif)

We started showing this to customers, and the response was simply overwhelming. *"We want this!"* they said after nearly every demo - the idea that you could just *ask* for what you needed and have the right UI appear, instead of clicking through menus and tabs, clearly struck a chord.

But there was a problem: the technology simply wasn't there. These were just demos, and even though the benefits of agent UIs were clear, shipping this to customers felt a long way off. 

## Some specs, finally

But then last autumn, things started happening. First, quietly on the open-source side, [MCP-UI](https://github.com/MCP-UI-Org/mcp-ui) showed up - an early attempt at formalizing how agent UIs could be served over MCP ([Here's my demo](https://www.linkedin.com/posts/andreasadner_%F0%9D%90%8D%F0%9D%90%9E%F0%9D%90%B0-%F0%9D%90%AF%F0%9D%90%A2%F0%9D%90%9D%F0%9D%90%9E%F0%9D%90%A8-using-mcp-ui-to-add-activity-7366158904004685825-GVsw?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) from August)- Then the frontier labs followed:

- [OpenAI Apps SDK](https://developers.openai.com/apps-sdk) — announced in October
- [MCP Apps](https://modelcontextprotocol.io/extensions/apps/overview) — announced in November, as an extension to the MCP protocol from Anthropic.

MCP Apps was directly inspired by MCP-UI, so credit to the MCP-UI team for paving the way.

Going back a bit further - last summer, a small, then-unknown company called CopilotKit released [AG-UI](https://docs.ag-ui.com/introduction), the spec that, more than any other, piqued my interest in agent UIs. I've since explored it in depth, including a session [at AgentCon](https://globalai.community/chapters/stockholm/events/agentcon-stockholm/) ([video summary](https://www.youtube.com/watch?v=PeEE5kYwdgo)) and in a [conversation with Rasmus Wulff Jensen](https://www.youtube.com/watch?v=QOlQAEAhIZI). For deeper dives, see my LinkedIn writeups [here](https://www.linkedin.com/posts/andreasadner_dynamic-ai-user-interfaces-with-microsoft-activity-7398088200042315776-ygSA?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) and [here](https://www.linkedin.com/posts/andreasadner_copilotkit-version-15-microsoft-agent-activity-7413675309042147328-dk2Q?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w).

One specific concept in AG-UI - [Shared state](https://docs.ag-ui.com/concepts/state) between the UI and the agent orchestrator, and a core part of the AG-UI spec - is, in my view, the single biggest unlock for agent UIs, and one piece that is still missing as these support for agent UIs finally land in mainstream Microsoft tools. Shared state unlocks some really transformative user experiences, such as these ones:

<iframe width="560" height="315" src="https://www.youtube.com/embed/PeEE5kYwdgo?si=hJr29_XzMX8gZZfD" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

Suddenly, the demos from a year earlier didn't look quite so far-fetched - the pieces in the agentic UI puzzle were starting to come together.

## The death of BizApps
So while agent UI standards started emerging at the end of last year, support for them was still lacking in the Microsoft ecosystem. Our customers were eager to start trying these experiences in Microsoft Teams and M365 Copilot, but as it turned out - they would've to wait a bit longer.

But inside Microsoft, these kind of ideas had apparently been brewing for quite some time. Already back in December 2024, on the [BG2 podcast](https://www.bg2pod.com/) Satya Nadella famously predicted the eventual death of SaaS-applications as we know them, in favor AI orchestration layers that serves agents directly.

Charles Lamanna was even blunter. In a [May 2025 conversation with Madrona](https://www.madrona.com/the-end-of-biz-apps-ai-agility-and-the-agent-native-enterprise-from-microsoft-cvp-charles-lamanna/) he said:

*"As the guy at Microsoft who works on business applications, sometimes the truth hurts, but business apps as we know it are indeed dead ... Instead, what will probably happen is you’ll see this ossification of these classic biz apps, the emergence of this new AI layer, which is very focused around automation and completing tasks in a way that extends the team of humans and people with these AI agents that go and do work ..  You’re going to have a generative UI, which AI dynamically authors and renders on the fly to exactly match what the person’s trying to do .. The gist of it is yes, indeed, biz apps, the age of biz apps is over."*

## The coming war of the AI Capabilities Layer
And it's not just the apps. At the Power Platform Community Conference 2025 in Las Vegas, Lamanna delivered the line that lit up the low-code community: *"Low code is dead, as we know it."* That caused quite a stir - but six months on, it looks less like the low-code frameworks themselves are dying, and more like the way we *use* them is changing. Instead of clicking around a designer to build a low-code app, we're letting our agents build them for using a CLI. See for example [this demo](https://www.linkedin.com/posts/andreasadner_copilotstudio-activity-7452038499995799552-GtfN?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) of Copilot Studio agents built with Claude Code and agent skills. 

I, for one, didn't see this coming.

Another harbinger of things to come - and one I have quoted repeatedly - is Lane Swenka's [blog post](https://devblogs.microsoft.com/powerplatform/power-platform-api-and-sdks-from-ux-first-to-api-first/) from last summer, laying out a new direction for Power Platform admin tools: a transition from UX-first to API-first. The scope was seemingly limited to admin tooling, but in hindsight it was pretty clear that it pointed to something bigger - an API-first shift across the whole Power Platform, to cater for the needs of AI agents.

Recetly, this [article](https://www.linkedin.com/pulse/capabilities-layer-todd-trotter-girqc/) by [Todd Trotter](https://www.linkedin.com/in/todd-trotter-01818030/) about the *Capabilities Layer* - the architecture and plumbing needed to serve AI agents - is one of the best summaries I've read of where all this is heading, and what it means for the Power Platform.

*"AI needs applications to describe what they can do, what their constraints are, and what state they are operating against. They need a surface that is designed to be composed ... That surface is the **Capabilities Layer**. It sits between your application services and any consumer - human, agent, or orchestrator - and it exposes typed tools, structured data resources, and interactive UX components through MCP."*

One concept in particular stands out — the idea of "micro frontends":
 
*"Micro-frontends apply service-style decomposition to the user interface by splitting the frontend into independently developed and deployed features or components that are composed into a larger experience."*

Some corporate-speak, sure - but he's basically saying the same thing as Charles Lamanna was saying (see above): the user experiences of the future will surface when they're needed, with just the UI elements the user needs, no more, no less. We're heading toward a world where dynamically surfaced, agent-centric *"micro experiences"* are the norm.

So the vision from Microsoft is pretty clear: agentic user experiences FTW, and the infrastructure, APIs and MCPs to support them. And they're not the only ones reaching this conclusion - Salesforce's recent [Headless 360 announcement](https://www.salesforce.com/news/stories/salesforce-headless-360-announcement/) is the same play, and SAP, ServiceNow and the rest are doing it also. The platforms are being (re)built to be consumed by an army of autonomous agents, and the human-facing UIs - when they're needed - will be dynamic and invoked by the agents.

The writing is on the wall, this is the war that's coming. And when the dust settles, the winner will be the provider with the best **Capabilities Layer** for agents — and the best support for agent UIs.

But vision is one thing; execution is another. With the coming clash of the titans to build the best capabilities layer as backdrop, let's look at what Microsoft has actually shipped lately in this space.

## The rise of the agentic Power Platform
In all honestly, being passionate about agent user experiences and at the same time being a consultant in the Microsoft space last year, wasn't all that great. With the explosion of specifications in the agent UI space we saw late last year, I had high hopes that these capabilities would be promptly made available in the Microsoft tech stacks. Perhaps support for MCP Apps for Copilot Studio agents? Or why not an iteration upon the Adaptive Card spec to support the same behaviour? Or maybe AG-UI support in M365 Copilot? One could only dream...

But Ignite 2025 came and went without any real announcements in this space, so I kept waiting and hoping, hoping and waiting. And good things to those who wait, because on the 9th of March, somewhat hidden in the Microsoft [365 Copilot Blog](https://techcommunity.microsoft.com/blog/microsoft365copilotblog/enable-agents-to-bring-apps-into-the-flow-of-work%E2%80%94while-keeping-it-in-control/4499464) was this little nugget:

![alt text](/images/260503/image.png)

Support for OpenAI Apps SDK was already available, and MCP Apps coming soon. I found some [really cool samples](https://github.com/microsoft/mcp-interactiveUI-samples) which I used to create [my own demo](https://www.linkedin.com/posts/andreasadner_copilot-mcp-activity-7441598020539908097-_JA6?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w):

![](/images/260503/2.gif)

This feature was part of a capability exclusive to Microsoft 365 Copilot **declarative agents**, marketed as "interactive UI widgets", part of "MCP plugin actions" (more info [here](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/declarative-agent-ui-widgets)). 

For some reason, all these new fancy capabilities related to support for agentic UI protocols was implemented for *declarative agents*, a technology I hadn't tried before - I had mostly dabbled with Copilot Studio agents and agents built with custom code (referred to as [*custom engine agents*](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/overview-custom-engine-agent) in the M365 Copilot nomenclature). So this gave me the chance to explore declarative agents, which was pretty interesting. 

Then, it was announced that that it is possible to use [M365 Copilot agents in a Power App](https://learn.microsoft.com/en-us/power-apps/user/use-microsoft-365-copilot-model-driven-apps). At first glance, the main benefit of this is to run the main M365 Copilot agent from a Power App - which is already grounded in your organization data, but which now also indexes the data in your Power App environment, which opens up some cool possibilities:

![](/images/260503/3.gif)

A [limitation](https://learn.microsoft.com/en-us/power-apps/user/use-microsoft-365-copilot-model-driven-apps#limitations) of this "standard" M365 Copilot agent is that it can't really "do" anything in Dataverse - it can read data just fine, but it can't modify anything. 

To remedy this, you can also [access your custom agents](https://learn.microsoft.com/en-us/power-apps/user/use-microsoft-365-copilot-model-driven-apps#use-agents-in-microsoft-365-copilot) (declarative, Copilot Studio or custom engine agent) from M365 Copilot in your Power App, and this is where it starts to become really cool! I created a [demo](https://www.linkedin.com/posts/andreasadner_microsoftcopilot-activity-7444647079043289089-HcpT?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) of this, once again using the Microsoft samples. This means that if your custom agent is equipped with e.g. the Dataverse MCP Server, it can update data in Dataverse. One big limitation currently is that the custom agent has no context - it doesn't know which Power App/form/view/record that it is using:

![alt text](/images/260503/image-1.png)

I hope that this will change soon!

Next was the [announcement](https://www.microsoft.com/en-us/power-platform/blog/power-apps/public-preview-your-business-apps-now-part-of-every-conversation/) that your Power App could [expose its own MCP Server](https://learn.microsoft.com/en-us/power-apps/maker/model-driven-apps/enable-your-app-copilot), which came with a set of custom MCP Apps UI tools. You couldn't then download it as a declarative Copilot agent. I created a [demo](https://www.linkedin.com/posts/andreasadner_dataverse-powerapps-microsoftcopilot-activity-7445817384805916672-E9Ue?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) of this also:

<iframe src="https://www.linkedin.com/embed/feed/update/urn:li:ugcPost:7445718741906137089?collapsed=1" height="541" width="504" frameborder="0" allowfullscreen="" title="Embedded post"></iframe>

Then came the [announcement](https://www.microsoft.com/en-us/power-platform/blog/2026/04/22/custom-tools-and-rich-ui-for-app-based-conversations-are-now-in-public-preview/) that custom tools could be added to your Power Apps, which became part of the MCP plugin actions, when you exported the Power Apps as a declarative agent. Demo [here](https://www.linkedin.com/posts/andreasadner_microsoftcopilot-powerplatform-activity-7452963921768067073-S9ns?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w).

And then on April 7 came the [big one](https://devblogs.microsoft.com/microsoft365dev/mcp-apps-now-available-in-copilot-chat/) - [support for MCP Apps](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/declarative-agent-ui-widgets) in declarative Copilot agents! Since I had [already created](https://www.linkedin.com/posts/andreasadner_building-my-own-crm-in-vs-code-using-mcp-activity-7427324074483302400-F52e) an MCP Server with some cool looking MCP Apps UI components, I simply added them to a declarative agent which resulted in my most successful [LinkedIn post](https://www.linkedin.com/posts/andreasadner_powerapps-microsoftcopilot-activity-7448784585456357376-X9bX?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) to date:

<iframe src="https://www.linkedin.com/embed/feed/update/urn:li:ugcPost:7448665788577832960?collapsed=1" height="754" width="504" frameborder="0" allowfullscreen="" title="Embedded post"></iframe>

And there is more, for example the [agent feed](https://learn.microsoft.com/en-us/power-apps/user/supervise-agents-with-agent-feed) capability in Power Apps (demo [here](https://www.linkedin.com/posts/andreasadner_powerapps-copilotstudio-activity-7454575199213170688-vAIM?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w)) and the possibilities of using your own [custom agents in Microsoft 365 productivity apps](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/build-api-plugins-local-office-api), such as Excel and Word (demo [here](https://www.linkedin.com/posts/andreasadner_powerapps-microsoftcopilot-activity-7451321150292480001-G59w?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w)).







