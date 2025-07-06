---
layout: post
title:  "Self healing plugins in Dataverse using Claude, MCP and Github"
date:   2025-07-06
categories: dataverse mcp
---
A while back I posted a [video](https://www.linkedin.com/posts/andreas-adner-70b1153_claudecode-github-copilot-activity-7340113552575193089-MU7B?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) to LinkedIn, showing how Claude Code could be used to 'self heal' Dataverse plugins. The post was a little sparse on detail, so in this blog post my intention is to provide a step-by-step instruction on how to get this demo up and running in your own environment. <!--end_excerpt-->

### Step 1 - Setting up a local Dataverse MCP Server
Although there is a great [MCP Server for Dataverse](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-mcp) available from Microsoft, for this particular demo I have created my own MCP Server that can be found [here](https://github.com/adner/SimpleDataverseMcpServer). It has two tools:

- **WhoAmI** - Executes a `WhoAmI` request and returns the result.
- **ExecuteFetch** - Executes a FetchXml request and returns the result. 

Modify `Program.cs` and provide your own environment URL, Client ID and Client Secret. It is assumed that the Client ID is setup as an [application user](https://learn.microsoft.com/en-us/power-platform/admin/manage-application-users?tabs=new#create-an-application-user) in your environment.

Build the MCP Server and make a note of the location of the resulting `McpServer.exe` file. This will be used later to setup the MCP Server in Claude Code.

Now let's make sure that the MCP Server works! A simple way is to use the [MCP Inspector](https://github.com/modelcontextprotocol/inspector).

![MCP Inspector](/_posts/images/250706_1.gif)


 