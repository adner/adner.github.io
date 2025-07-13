---
layout: post
title:  "Evaluation of large language models with Dataverse MCP Server"
date:   2025-07-13
categories: dataverse mcp llm
image: /images/250706_0.png
---
![title](/images/250713/titleimage.png)
In a number of posts on LinkedIn I have demonstrated various ways of using the [Dataverse MCP Server](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-mcp) from Microsoft, which allows access to data in Dataverse from your AI tool of choice (assuming it is an [MCP Client](https://modelcontextprotocol.io/clients)):

- In [this](https://www.linkedin.com/posts/andreas-adner-70b1153_dataversemcpserver-activity-7344003681740075008-W3x4?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) post, I showed how the Dataverse MCP Server can be used from Claude Code, Claude Desktop and Gemini CLI. 
- In [this](https://www.linkedin.com/posts/andreas-adner-70b1153_dataverse-mcp-server-running-from-excel-activity-7345177569844953088-H3Y9?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) post I demonstrated how the Dataverse MCP server can be used from anywhere - in this case from Excel, implemented as a VBA macro.

While the Dataverse MCP Server allows access to Dataverse by exposing several [tools](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-mcp#list-of-tools-available-in-dataverse-mcp-server), the job of calling these tools is entirely up to the Large Language Model that is using the MCP Client. If the model doesn't know when to call the tools and how to interpret the results, the tools are useless! 

So, this begs the question - which Large Language Model is best when it comes to using the Dataverse MCP Server? I tried to evaluate this, and showed some quick demonstrations in [this](https://www.linkedin.com/posts/andreas-adner-70b1153_benchmark-of-llms-using-dataverse-mcp-server-activity-7348442438119665665-lLhZ?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) and [this](https://www.linkedin.com/posts/andreas-adner-70b1153_dataversemcp-semantickernel-llmevaluation-activity-7349537355499745281-42j8?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) post on LinkedIn. These posts just scraped the surface of the topic, and in this blog post I intend to dive deeper, evaluate more models and also give a technical overview of how this evaluation was done.

If you are just interested in the technical setup, you can skip ahead [skip ahead](#technical-overview).

## Model evaluation

![gpt35turbo](/images/250713/gpt35turbo.webp)

## Technical overview