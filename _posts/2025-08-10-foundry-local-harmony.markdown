---
layout: post
title:  "Foundry Local, the new OpenAI models and the Harmony response format"
date:   2025-08-10
image: /images/250810/title.png
---
![title](/images/250810/title.png)
About a week ago (prior to the release of the highly anticipated GPT-5 model), OpenAI released its first open weights model since GPT-2, the `gpt-oss-20b` and `gpt-oss-120b` models.

I tried out `gpt-oss-20b` (the 20 billion parameter model) using **LM Studio**, and recorded a [video](https://youtu.be/Gj388QWF1Kw?si=Py_Z-wMryXwcalOD) showing how well the model handles tool-calling, using the [Dataverse MCP Server](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-mcp).<!--end_excerpt--> It turned out to work very well - at least in comparison to other models in my [Pizza Party benchmark](https://nullpointer.se/dataverse/mcp/llm/2025/07/14/dataverse-llm-evaluation.html). 

A week after its release, the reviews of the OpenAI OSS models are somewhat [mixed](https://www.perplexity.ai/search/summarize-the-general-feedback-b_zgi73iRLOa5945YUiMPA), but mostly positive. My overall feeling is that the model (I have only done very limited tests of the 120b model) is very capable, especially when it comes to tool calling - and it is very fast!

A couple of days following the release, Microsoft [announced](https://www.linkedin.com/posts/rajiraj_excited-to-share-that-the-brand-new-oss-activity-7358936015350194176-q_O3?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) that the gpt-oss models were available to run on [Foundry Local](https://learn.microsoft.com/en-us/azure/ai-foundry/foundry-local/what-is-foundry-local), an on‑device AI inference solution currently in preview.

I have wanted to test Foundry Local for a while, and I thought it would be interesting to see how well it could host the OpenAI models. 

Foundry Local provides an OpenAI compatible [REST API](https://learn.microsoft.com/en-us/azure/ai-foundry/foundry-local/reference/reference-rest) that lets you use the models from any AI chat clients that can use an OpenAI API endpoint. After testing out a couple of such clients, it became clear that none of the clients (that I tried) supported the new [Harmony](https://github.com/openai/harmony) response format that the models use. The format looks like this:

![alt text](/images/250810/harmony.png)

I wanted a client that could show the model's "train of thought" in a nice way, without all the Harmony tags. So, I decided to *vibe-code* my own client (using GPT-5, of course), the result is shown in the [video](https://youtu.be/Drw7kUblmFM?si=mdc5yuMX5TrZJ7iY) below, and the code can be found in [this repo](https://github.com/adner/OpenAI_Harmony) in GitHub.

I used [Microsoft.Extensions.AI](https://learn.microsoft.com/en-us/dotnet/ai/microsoft-extensions-ai) in the demo, and one gotcha that I encountered was that I had to increase the `MaxOutputTokens` value, otherwise the response was cut off - I guess that the default value isn't very high.

<iframe width="560" height="315" src="https://www.youtube.com/embed/Drw7kUblmFM?si=q2DctuvCOtwVR31K" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>



