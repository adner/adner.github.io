---
layout: post
title:  "Running Microsoft Agent 365 MCP Servers from a custom agent"
date:   2025-12-02
image: /images/251205/splash.png
permalink: /agent-365-mcp-servers-part-2.html
---
{% if page.image %}
  <a href="{{ page.url | relative_url }}">
    <img src="{{ page.image | relative_url }}" alt="{{ page.title }}">
  </a>
{% endif %}

In the [last blog post](https://nullpointer.se/agent-365-mcp-servers-part-1.html) I demonstrated how to connect to some of the MCP Servers that are part of the [tooling servers](https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview) in Agent 365. We used the tools [MCP Inspector](https://github.com/modelcontextprotocol/inspector) and [Postman](https://www.postman.com/) to do this. In this blog post the goal is to use these MCP Servers from Microsoft Agent Framework, and present the resulting agent in a custom UI that uses [CopilotKit](https://www.copilotkit.ai/) and the [Agent-User Interaction Protocol](https://github.com/ag-ui-protocol/ag-ui) (AG-UI).<!--end_excerpt-->

