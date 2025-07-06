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

### Step 2 - Fork the repo
The repo containing the code and configurations for the demo can be found [here](https://github.com/adner/ClaudeDemo). Fork the repo and clone it locally.

Now, update `dataverseMcp.sh` to point to the location of your `McpServer.csproj` file, from the previous step. This makes sure that Claude Code can access the MCP Server, in the next step.

### Step 3 - Get Claude Code running
[Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) is a CLI tool from Anthropic, that is included in the Claude Pro-subscription and that can be used - among other things - to use MCP Servers. At this time, Claude Code cannot run natively in Windows - it requires Windows Subsystem for Linux (WSL).

- Instructions on how to install WSL can be found [here](https://learn.microsoft.com/en-us/windows/wsl/install).
- Setup instructions for Claude Code can be found [here](https://docs.anthropic.com/en/docs/claude-code/setup).

Make sure that [Node](https://nodejs.org/en/download) is installed, fire up WSL and run the following command to install Claude Code globally:

```npm install -g @anthropic-ai/claude-code```

Then, navigate to where you cloned the repo and start `claude`. If you get a question to use existing MCP configurations, say yes. You can now check that the MCP Server is working:

![image](/images/250706_2.webp)

Is MCP working? Great!

### Step 4 - Build and deploy the plugin with the issue
Run `dotnet build` to build the plugin assembly. If you don't have the Power Platform CLI, [install it](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction?tabs=windows). Then start the Plugin Registration Tool using the command `pac tool prt` and register `PluginTest.dll` on updates of the *mobilephone* field of the the *Contact* table:

![Pluginregistration](/images/250706_3.png)

We have now deployed a plugin with a subtle issue - if the mobilephone number *+-()_* is entered, an exception is thrown:

![Pluginissue](/images/250706_4.webp)

Make sure that plugin in tracing is enabled, as described [here](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/logging-tracing#enable-trace-logging).

### Step 5 - Overview of the repo, and some additional config.

Before proceeding, make sure that you have [Github CLI](https://cli.github.com/) set up locally.

If you go to github and review the repo that you forked, you can see that it has two Actions defined under `.github/workflows`:
- `claude.yml` - Contains a configuration for running Claude as an agent it Github, as shown in the LinkedIn video. It requires some additional configuration in the repo settings, as is described [here](https://docs.anthropic.com/en/docs/claude-code/github-actions). 
- `test.yml` - An Action that builds and tests the plugin if a pull request is created. Since Dataverse plugins are .NET 4.6.2, this requires some special configuration.

You can run the tests manually to make sure they work:

![tests](/images/250706_5.webp)

To be able to update the plugin automatically in Dataverse, the file `updatePlugin.sh` needs to be updated with the ID of the plugin assembly, and the location of the plugin file on disk. The easiest way of getting the assembly ID, is to enter the following URL into the address bar:

```https://[EnvironmentName].dynamics.com/api/data/v9.0/pluginassemblies?$select=pluginassemblyid,name```

![image](/images/250706_6.png)

### Step 6 - Use Claude Code to find the plugin issue

Review `Claude.MD`, it gives specific instructions to Claude Code on how to find plugin issues and fix them.

You can now ask Claude if there are any issues, and the AI should identify them, fix the issue, scaffold and run a test and then create a PR:

![movie](/images/250706_7.webp)

If you look in your repo, you should see that a PR has been opened, and that the tests are running automatically, and once they success the PR is ready to be merged:

![image](/images/250706_8.png)

Once the merge has been completed, you can tell Claude to get the latest code and update the assembly in Dataverse:

![image](/images/250706_9.webp)











 