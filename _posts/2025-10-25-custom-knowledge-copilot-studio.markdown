---
layout: post
title:  "Custom knowledge sources in Copilot Studio"
date:   2025-10-18
image: /images/251025/splash.png
---
{% if page.image %}
  <a href="{{ page.url | relative_url }}">
    <img src="{{ page.image | relative_url }}" alt="{{ page.title }}">
  </a>
{% endif %}

A while back, there was an [interesting discussion on Matthew Devaney's LinkedIn post](https://www.linkedin.com/posts/matthew-devaney_copilotstudio-fetchxml-activity-7385652147083866112-0w0l/), regarding whether it was possible to use FetchXml Dataverse queries as the basis for Knowledge Sources in Copilot Studio. [Andreas Aschauer](https://www.linkedin.com/in/aaschauer/) suggested in a comment that the OnKnowledgeRequested trigger in Copilot Studio could be used to create a custom Knowledge Source, so I thought I'd try it out for myself. 

I posted a [video on **LinkedIn**](https://www.linkedin.com/posts/andreas-adner-70b1153_copilotstudio-dataverse-activity-7387129735799091201-Uav9) that shows how a custom knowledge source can be created in Copilot Studio, that calls Dataverse using FetchXml. This blog post describes in detail how this was accomplished, so that you can try it out for yourself.

<!--end_excerpt-->

### Creating the custom Knowledge Source Topic in Copilot Studio

There isn't much documentation available on how to use the OnKnowledgeRequested trigger, but I found [a great post by Samir Pathak](https://www.linkedin.com/pulse/adding-custom-enterprise-knowledge-sources-copilot-samir-pathak-pmp-j4oze/), as well as [a blog post](https://microsoft.github.io/mcscatblog/posts/copilot-studio-custom-knowledge-source/) from the Microsoft Copilot Studio CAT team, that provides guidance.

The Microsoft blog post writes the following about the OnKnowledgeRequested trigger:

![alt text](/images/251025/image.png)

This means that in order to create a custom Knowledge Source we need to create a new Topic in Copilot Studio, and use the code editor to configure the Topic to use the OnKnowledgeRequested trigger:

![alt text](/images/251025/image-1.png)

When this configuration is done, the rest of the Topic can be configured using the graphical editor. First, we set a variable that contains the FetchXml query that we want to use:

![alt text](/images/251025/image-2.png)

Then, we use the HTTP Request action to call an Azure Function that is responsible for calling Dataverse and respond in a format that Copilot Studio understands (more on the Azure Function below), and saves the response to a variable:

![alt text](/images/251025/image-3.png)

Lastly, we set the system variable `System.SearchResults` to the variable that contains the result from the Azure Function. This instructs Copilot Studio to interpret the result as a Knowledge Source.

![alt text](/images/251025/image-4.png)

It should be noted that my implementation differs from what is described in the Microsoft [blog post](https://microsoft.github.io/mcscatblog/posts/copilot-studio-custom-knowledge-source/) in a number of ways:

- I actually don't use the `System.SearchQuery` and `System.KeywordSearchQuery` system variables at all in this example. I simply call the Azure Function with the FetchXml query that is set in the Topic, regardless of the actual query that was made by the user. So, this means that Copilot Studio checks the custom Knowledge Source regardless of what the user was actually asking for. This could be improved so that the knowledge source is only called when it is relevant for the query. 

- In the blog post the result from the knowledge source is transformed to the format that is required for the `System.SearchResults` variable, and this transformation is done in the Topic. In my example, the Azure Function is responsible for doing this transformation. 

### The custom knowledge source Azure Function

I created a simple Azure Function that can be called from the Topic, and that calls Dataverse using the supplied FetchXml query, and transforms the result to a format that Copilot Studio can use as a Knowledge Source result. The code for the Function can be found in [this repo](https://github.com/adner/FetchXmlFunction).

If we run the Function locally, and call it using for example Postman, we can see the structure of the JSON result that it returns:

![alt text](/images/251025/image-5.png)

Copilot Studio expects the following format in responses from a Knowledge Source:

- **Content (mandatory)**: The search snippet or text excerpt
- **ContentLocation (optional)**: The URL of the full document
- **Title (optional)**: The title of the document or search result

As can be seen above, we only return the **Content** and **ContentLocation** attributes. Also, we are using a special format for **Content** string, which is basically just a concatenation of all the attributes that are returned by the FetchXml query, similar to this:

`ContactName:Rene Valdes (sample), contactid:7abc6bf7-8a7b-f011-b4cc-7c1e5237e7bd, CompanyName:A. Datum Corporation (sample)`

This means that we can make the results easier to understand for Copilot Studio by making the column names as illustrative as possible. A good way of doing this is to ***alias*** the column names in the FetchXml query:

```xml
<fetch top="50">
  <entity name="contact">
    <attribute name="fullname" alias="ContactName" />
    <link-entity name="account" from="accountid" to="parentcustomerid" link-type="inner" alias="Company">
      <attribute name="name" alias="CompanyName" />
    </link-entity>
  </entity>
</fetch>
```
The Azure Function has code for extracting the aliased column values from the query result, and formatting them in the way that Copilot Studio expects. The code is just a start and doesn't cover all types of queries, but can easily be expanded upon.

This is what it looks like when it is running in Copilot Studio:

<iframe width="315" height="560"
src="https://youtube.com/shorts/FLCd1vWAhnw?si=ESTkU1aG-9vNwW65"
title="YouTube video player"
frameborder="0"
allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
allowfullscreen></iframe>

