---
layout: post
title:  "Fun with AI Agents and the EU AI Act"
date:   2025-09-24
image: /images/250924/250924_splash.png
---
{% if page.image %}
  <a href="{{ page.url | relative_url }}">
    <img src="{{ page.image | relative_url }}" alt="{{ page.title }}">
  </a>
{% endif %}

2025 is shaping up to be the year when many organizations move beyond AI “proof of concepts” and start deploying AI chatbots and AI agents "for real". Over the past months, I’ve had a number of interesting discussions with customers about how to approach this transition, and how to set up an AI infrastructure that is robust from both a technical and compliance perspective.

<!--end_excerpt-->

### The many joys of GDPR and the EU AI Act

Since I’m based in the EU, most customer conversations naturally involve compliance topics involving the General Data Protection Regulation (GDPR). GDPR has been a central theme for many years, and when doing pre-studies and implementations we try to make sure to always include the customer's Data Protection Officer (DPO) in the project, to make sure that all GDPR concerns - such as data minimization, lawful basis for processing, handling of personal data in third countries, retention policies, etc, are properly addressed. 

There's a fine balance that needs to be struck here. Organizations need to be able to get on with their core business, and things can't be allowed to grind to a halt every time a GDPR question pops up. So, the DPO has a tricky but important role: acting as the guardian of data integrity, while also making sure that the business can continue to operate and innovate, without being being bogged down by GDPR compliance concerns. In my experience, a "good" DPO looks at technology as an opportunity to strengthen compliance and personal integrity, while a “less good” one sees technology mainly as a risk or a threat. Paradoxically, the fear of "the new" can sometimes be so strong that it keeps customers stuck on outdated, less secure solutions that does not address GDPR properly. 

A good DPO knows that technology is a great enabler when it comes to GDPR compliance. See for example [this](https://www.youtube.com/watch?v=d-cKv9Cj1Ss) video where I show how the automation framework [N8N](https://n8n.io/) can be used together with AI to automatically detect GDPR non-compliance in Dataverse.

And now, more legislation is coming and now we also have to factor in the [EU AI Act](https://artificialintelligenceact.eu/), which introduces new requirements for AI systems. It’s expected to be fully in place by the end of 2027, which means it’s not something we can just ignore for later. Just like GDPR became a natural part of every project, the AI Act now has to be part of the conversation when planning how AI will be used across organizations. And similar to GDPR, the DPO needs to find a way of balancing the legal requirements with the organization’s need to innovate and continue doing its business...

In this blog post, I’ll share some thoughts around both technical AI infrastructure, as well as touching upon on how the EU AI Act fits into this picture, and what organizations should start considering as they expand their use of AI.

What is presented below is by no means a complete reference architecture for enterprise AI deployment or a deep-dive into the EU AI Act. Rather, it’s more of a collection of various insights and technologies that I’ve come across in my discussions with customers, and from my own explorations - many of which I have already shared in this blog and on LinkedIn.

### Moving on from Proof of concepts to deploying AI more broadly

![](/images/250924/Picture1.png)

Over the past two years, most enterprises have experimented with AI through small-scale "proof of concepts". In the Microsoft/Power Platform space that I operate in, this has often involved trying out Microsoft 365 Copilot, or the Copilots that are embedded in the different Dynamics 365 business applications. Some orgs have evaluated ChatGPT (which many users are familiar with from private use) or  Claude. I have seen some customers (not many) venturing into pro-code AI solutions, custom AI chat interfaces, MCP Server, etc. But most have simply evaluated various low-code/no-code solutions, with mixed results. 

In my experience, the most effective and eye-opening POCs have been the ones where **MCP Servers** were used to give AI access to tools. More than anything else, this is what tends to make customers realize the real potential of AI. Suddenly, it’s not just a chatbot that can answer questions - it is an agent that can actually do things - query the CRM-system, create documents, create reports, and more! Since MCP is still fairly new and, until recently, wasn't widely supported in low/no-code AI frameworks, these kinds of POCs have usually required a bit of "pro-code" effort. But the payoff in terms of customer understanding and excitement has been **huge**!

Many of these proofs of concept have been carried out in isolation. The focus has been on "seeing what's possible", not on designing for the long term. That means questions about architecture, scalability, and compliance have often been pushed aside for later. Sure, an AI chatbot that uses MCP Servers to call tools is cool and all — but what happens when you want to roll it out to more users? How do you build the infrastructure that makes the chatbot available in all the channels your organization needs, with the tools it needs - in a secure fashion?

So, now that the proof of concepts are completed the time has come to plan for wider rollout of AI applications, and to create an architecture that can actually support this. Below are some cool tech that I have found that might be able to help in this regard.

### The channel integration layer

![](/images/250924/Picture2.png)

Let’s talk about making AI available in the right channels. An AI agent should meet the user where they are, not the other way around. If someone spends their day in Teams and occasionally needs to use AI and MCP to query the CRM for details about for example incidents, then the agent should be available in Teams. The same agent, once built, might also need to serve a completely different user group in another channel - for example a custom user interface specifically tailored for that user. We should be able to make that shift seamlessly. That’s  the purpose of the **Channel Integration Layer**: enabling a build once, deploy anywhere approach. 

The [Microsoft 365 Agents SDK](https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/agents-sdk-overview?tabs=csharp) does exactly this, and more. It manages authentication, allows deployment to a myriad of channels , manages state och conversations, and can be run on top of different technology stacks/AI orchestration frameworks. Developing your AI solutions using this framework makes them portable and reusable, and greatly simplifies the effort of deploying AI agents to different channels in secure way. 

[Here](https://youtu.be/CY8_Mm3lfk4?si=GiaadUk-nGzjQJoj) is a great introduction video that explains the purpose of the M365 Agents SDK, and where it fits in to the overall AI Architecture. More information can be found in the [GitHub repo](https://github.com/microsoft/Agents).

M365 Agents SDK can be used whether you want to create an agent using a low-code framework like Copilot Studio, or if you want to use a "pro-code" AI orchestration framework like [Semantic Kernel](https://learn.microsoft.com/en-us/semantic-kernel/overview/) or [LangChain](https://github.com/tryAGI/LangChain). 

In [this](https://www.youtube.com/watch?v=wR_6xDDlHwo) and [this](https://www.youtube.com/watch?v=wR_6xDDlHwo)  YouTube videos I demonstrate how the the [Copilot Studio Client](https://github.com/microsoft/Agents/tree/main/samples/dotnet/copilotstudio-client) (that is part of the SDK) can be used as the orchestrator for a custom agent UI running in the browser. This is a really powerful pattern where the Copilot Studio can be used to quickly add new capabilities to a completely custom AI UI experience, without having to write any code.

[TO BE CONTINUED]