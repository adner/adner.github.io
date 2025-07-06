---
layout: post
title:  "Self healing plugins in Dataverse using Claude, MCP and Github"
date:   2025-07-06
categories: dataverse mcp
image: /images/250706_2.webp
---
A while back I posted a [video](https://www.linkedin.com/posts/andreas-adner-70b1153_claudecode-github-copilot-activity-7340113552575193089-MU7B?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) to LinkedIn, showing how Claude Code could be used to 'self heal' Dataverse plugins. The post was a little sparse on detail, so in this blog post my intention is to provide a step-by-step instruction on how to get this demo up and running in your own environment. <!--end_excerpt-->

### Step 1 - Setting up a local Dataverse MCP Server
Although there is a great [MCP Server for Dataverse](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-mcp) available from Microsoft, for this particular demo I have created my own MCP Server that can be found [here](https://github.com/adner/SimpleDataverseMcpServer). It has two tools:

- **WhoAmI** - Executes a `WhoAmI` request and returns the result.
- **ExecuteFetch** - Executes a FetchXml request and returns the result. 

Modify `Program.cs` and provide your own environment URL, Client ID and Client Secret. It is assumed that the Client ID is setup as an [application user](https://learn.microsoft.com/en-us/power-platform/admin/manage-application-users?tabs=new#create-an-application-user) in your environment.

Build the MCP Server and make a note of the location of `McpServer.csproj` file. This will be used later to setup the MCP Server in Claude Code.

Now let's make sure that the MCP Server works! A simple way is to use the [MCP Inspector](https://github.com/modelcontextprotocol/inspector).

![MCP Inspector](/images/250706_1.webp)

### Step 2 - Clone the repo
The repo containing the code and configurations for the demo can be found [here](https://github.com/adner/ClaudeDemo). Clone the repo:

```git clone https://github.com/adner/ClaudeDemo.git```

Now, update `dataverseMcp.sh` to point to the location of your `McpServer.csproj` file, from the previous step. This makes sure that Claude Code can access the MCP Server, in the next step.

### Step 3 - Get Claude Code running
[Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) is a CLI tool from Anthropic, that is included in the Claude Pro-subscription and that can be used - among other things - to use MCP Servers. At this time, Claude Code cannot run natively in Windows - it requires Windows Subsystem for Linux (WSL).

- Instructions on how to install WSL can be found [here](https://learn.microsoft.com/en-us/windows/wsl/install).
- Setup instructions for Claude Code can be found [here](https://docs.anthropic.com/en/docs/claude-code/setup).

Make sure that [Node](https://nodejs.org/en/download) is installed, fire up WSL and run the following command to install Claude Code globally:

```npm install -g @anthropic-ai/claude-code```

Then, navigate to where you cloned the repo and start `claude`. If you get a question to use existing MCP configurations, say yes. You can now check that the MCP Server is working:

![image](/images/250706_2.webp)







 