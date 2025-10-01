---
layout: post
title:  "Fun with AI Agents and the EU AI Act"
date:   2025-09-26
image: /images/250924/250924_splash.png
---
{% if page.image %}
  <a href="{{ page.url | relative_url }}">
    <img src="{{ page.image | relative_url }}" alt="{{ page.title }}">
  </a>
{% endif %}

2025 is shaping up to be the year when many organizations move beyond AI “proof of concepts” and start deploying AI chatbots and AI agents "for real". Over the past months, I’ve had a number of interesting discussions with customers about how to approach this transition, and how to set up an AI infrastructure that is robust from both a technical and compliance perspective.

<!--end_excerpt-->

### The many joys of GDPR and the good and the bad DPO:s

Of course, in the EU no discussion about AI deployment can happen without also addressing compliance. Since I’m based in the EU, most customer conversations naturally include compliance topics involving the [General Data Protection Regulation](https://gdpr.eu/) (GDPR). GDPR has been a central theme for many years, and when doing pre-studies and implementations we try to make sure to always work closely with the customer's [Data Protection Officer](https://gdpr-info.eu/issues/data-protection-officer/) (DPO), to make sure that various GDPR concerns - such as data minimization, lawful basis for processing, handling of personal data in third countries, retention policies, etc, are properly addressed. 

There's a fine balance that needs to be struck here. Organizations need to be able to get on with their core business, and things can't be allowed to grind to a halt every time a GDPR question pops up. So, the DPO has a tricky but important role: acting as the guardian of data integrity, while also making sure that the business can continue to operate and innovate, without being bogged down by GDPR compliance concerns. In my experience, a "good" DPO looks at technology as an **opportunity to strengthen compliance and personal integrity**, while a more risk-averse DPO may see technology mainly as a threat. Paradoxically, the fear of "the new" can sometimes be so strong that it keeps customers stuck on outdated, less secure solutions that do not address GDPR properly. 

A good DPO knows that technology can be a great enabler when it comes to achieving GDPR compliance. See for example [this](https://www.youtube.com/watch?v=d-cKv9Cj1Ss) video where I show how the automation framework [N8N](https://n8n.io/) can be used together with AI to automatically detect GDPR non-compliance in Dataverse. 

A recurring concern in customer conversations has been a feeling of uncertainty surrounding U.S. cloud providers and the risk of personal data being accessed or transferred to the U.S. government. Too often, this fear is rooted more in a "gut feeling" than in hard facts, and we have spent considerable time helping customers understand the many safeguards that Microsoft has put into place to minimize the risk that their data is accessed by the U.S. government - such as the [EU Data Boundary](https://learn.microsoft.com/en-us/privacy/eudb/eu-data-boundary-learn) and a commitment to [challenge every request](https://blogs.microsoft.com/on-the-issues/2020/11/19/defending-your-data-edpb-gdpr/) for access to customer data. 

I firmly believe that these safeguards makes it possible to manage personal data in the Microsoft Cloud in a secure and fully GDPR-compliant way. However, this requires that the customer’s data protection organization - led by the DPO - *understands* the technical and legal safeguards Microsoft provides and keeps pace as these safeguards evolve. For DPOs without the necessary technical knowledge or willingness to engage with these mechanisms, this can be a tall order, but it is still a non-negotiable responsibility when handling personal data in the cloud.

And importantly: keeping data out of the cloud often creates only a false sense of security. In reality, data breaches are far more common in on-premise environments than in the cloud, where providers like Microsoft invest billions annually in security, compliance, and continuous monitoring. 

In summary, avoiding the cloud for GDPR reasons and staying with outdated on-premise solutions is not a sound strategy - it is, in fact, a serious and ongoing risk for [GDPR violations and data breaches](https://www.lunduniversity.lu.se/home/information-regarding-cyber-attack-against-miljodata). 

### The EU AI Act

And now, more legislation is coming and we also have to factor in the [EU AI Act](https://artificialintelligenceact.eu/), which introduces new legal requirements for AI systems. It’s expected to be fully in place by the end of 2027, which means it’s not something we can ignore. Just like GDPR became a natural part of every project, the AI Act now has to be part of the conversation when planning how AI will be used across organizations. And similar to GDPR, the DPO needs to find a way of balancing the legal requirements with the organization’s need to innovate and continue conducting its business. 

In this blog post, I’ll share some thoughts around both technical AI infrastructure, as well as touching upon on how the EU AI Act fits into this picture, and what organizations should start considering as they expand their use of AI.

What is presented below is by no means a complete reference architecture for enterprise AI deployment or a deep-dive into the EU AI Act. Rather, it’s more of a collection of various insights and technologies that I’ve come across in my discussions with customers, and from my own explorations - many of which I have already shared in this blog and on LinkedIn.

### Moving on from Proofs of concept to deploying AI more broadly

![](/images/250924/Picture1.png)

Over the past two years, most enterprises have experimented with AI through small-scale "proofs of concept". In the Microsoft/Power Platform space that I operate in, this has often involved trying out Microsoft 365 Copilot, or the Copilots that are embedded in the different Dynamics 365 business applications. Some orgs have evaluated ChatGPT (which many users are familiar with from private use) or  Claude. I have seen some customers (not many) venturing into pro-code AI solutions, custom AI chat interfaces, [MCP Servers](https://modelcontextprotocol.io/docs/getting-started/intro), etc. But most have simply evaluated various low-code/no-code solutions, with mixed results. 

In my experience, the most effective and eye-opening POCs have been the ones where **MCP Servers** were used to give AI access to tools. More than anything else, this is what tends to make customers realize the real potential of AI. Suddenly, it’s not just a chatbot that can answer questions - it is an agent that can actually do things - query the CRM-system, create documents, create reports, and more! Since MCP is still fairly new and, until recently, wasn't widely supported in low/no-code AI frameworks, these kinds of POCs have usually required a bit of "pro-code" effort. But the payoff in terms of customer understanding and excitement has been **huge**!

Many of these proofs of concept have been carried out in isolation. The focus has been on "seeing what's possible", not on designing for the long term. That means questions about architecture, scalability, and compliance have often been pushed aside for later. Sure, an AI chatbot that uses MCP Servers to call tools is cool and all — but what happens when you want to roll it out to more users? How do you build the infrastructure that makes the chatbot available in all the channels your organization needs, with the tools it needs - in a secure fashion?

So, now that the proofs of concept are completed the time has come to plan for wider rollout of AI applications, and to create an architecture that can actually support this. Below are some cool tech that I have found that might be able to help in this regard.

### The channel integration layer

![](/images/250924/Picture2.png)

Let’s talk about making AI available in the right channels. An AI agent should meet the user where they are, not the other way around. If someone spends their day in Teams and occasionally needs to use AI and MCP to query the CRM for details about for example cases or opportunities, then the agent should be available in Teams. The same agent, once built, might also need to serve a completely different user group in another channel - for example a custom user interface specifically tailored for customer support reps. We should be able to make that shift seamlessly. That’s  the purpose of the **Channel Integration Layer**: enabling a build once, deploy anywhere approach. 

The [Microsoft 365 Agents SDK](https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/agents-sdk-overview?tabs=csharp) does exactly this, and more. It manages authentication, allows deployment to a myriad of channels, manages state and conversations, and can be run on top of different technology stacks/AI orchestration frameworks. Developing your AI solutions using this framework makes them portable and reusable, and greatly simplifies the effort of deploying AI agents to different channels in secure way. 

[Here](https://youtu.be/CY8_Mm3lfk4?si=GiaadUk-nGzjQJoj) is a great introduction video that explains the purpose of the M365 Agents SDK, and where it fits in to the overall AI Architecture. More information can be found in the [GitHub repo](https://github.com/microsoft/Agents).

M365 Agents SDK can be used whether you want to create an agent using a low-code framework like Copilot Studio, or if you want to use a "pro-code" AI orchestration framework like [Semantic Kernel](https://learn.microsoft.com/en-us/semantic-kernel/overview/) or [LangChain](https://github.com/tryAGI/LangChain). 

In [this](https://www.youtube.com/watch?v=wR_6xDDlHwo) YouTube video I demonstrate how the [Copilot Studio Client](https://github.com/microsoft/Agents/tree/main/samples/dotnet/copilotstudio-client) (that is part of the SDK) can be used as the orchestrator for a custom agent UI running in the browser. This is a really powerful pattern where the Copilot Studio can be used to quickly add new capabilities to a custom AI UI experience, without having to write any code.

### The orchestration layer

![](/images/250924/Picture3.png)

The Orchestration Layer consists of the frameworks we need to allow our AI agent to act intelligently - plan, reason and act, call tools and orchestrate swarms of special-purpose agents for different tasks. Framework that help here are e.g. Microsoft [Semantic Kernel](https://learn.microsoft.com/en-us/semantic-kernel/overview/), that I have used extensively in my explorations of AI - for example [this demo](https://youtu.be/k5Tc3AsMBls) where a custom AI agent uses Semantic Kernel to call tools that dynamically create documents and generate reports.

I have also explored how Copilot Studio can be used as a "no-code" agent orchestrator, for example in [this demo](https://youtu.be/6B60HVbnHmw) where Copilot Studio does the orchestration, and a [simple custom-built MCP Server](https://github.com/adner/SimpleDataverseMcpServer) is used to communicate with Dataverse.

It is in this layer where the magic happens and the AI gets access to the tools that it needs to provide real value. The [Microsoft Agent Framework](https://github.com/microsoft/agent-framework/) was just announced by Microsoft, which is the agent orchestration framework that will supersede Semantic Kernel, and is the given choice in this layer, once it reaches general availability.

### The Governance layer
![](/images/250924/Picture4.png)

If the Orchestration Layer is where the "magic" happens, then the Governance Layer is where we make sure that magic is allowed to happen in a compliant and controlled way. It's there to make sure that the AI goodness does not come at the expense of legal requirements, security, or organizational trust.

Microsoft's cloud stack already provides a strong foundation here. Tools such as Entra ID (identity, authentication, conditional access), Purview (data governance, lineage, auditing), and the EU Data Boundary (data residency and sovereignty) help address GDPR concerns directly. Since MCP is such an big game changer for AI in the enterprise, an MCP registry (for example [Azure API Center](https://learn.microsoft.com/en-us/azure/api-center/register-discover-mcp-server)) is needed, as well as mechanisms for authorizing access to the data and systems that the MCP:s use. For AI Act readiness, Microsoft is also investing heavily in Responsible AI tooling - dashboards, fairness and bias detection, model interpretability, and documentation frameworks that make it easier for organizations to meet requirements for human oversight, transparency, and **risk classification** of AI systems.

Yes, let’s talk about EU AI Act risk classifications. The legislation divides AI systems into four categories — **Unacceptable Risk**, **High Risk**, **Limited Risk**, and **Minimal/No Risk** — and understanding where your AI initiatives fall within this range is critical. At first glance, it might seem like your use-cases land safely in the “No Risk” bucket, that comes with no special regulatory obligations. But the devil is in the details. A surprisingly large number of real-world workloads actually belong to higher categories. For example: AI in recruitment or employee evaluation is classified as **high risk**. AI in credit scoring, healthcare, or law enforcement is likewise high risk, with strict obligations around documentation, human oversight, and conformity assessments.

So, Just like with GDPR, organizations need to do the hard work with the EU AI Act: understand their AI workloads and what’s required to comply. But compliance alone isn’t enough — these workloads also need to make it into production. And without a solid architecture in place, your AI efforts will not scale and compliance will be hard to achieve.

So, a solid AI architecture isn’t just nice to have, it’s essential. Without it, taking the step from proofs of concept to organization wide AI usage will be a challenge.

A layered architecture, like the one depicted below, could serve as an example of how organizations can set up an infrastructure that enables the move from isolated AI experiments to enterprise-grade deployments that are scalable, secure, and compliant with both GDPR and the EU AI Act.

Thanks for reading!

<a href="/images/250924/Picture5.png" target="_blank">![](/images/250924/Picture5.png)</a>
