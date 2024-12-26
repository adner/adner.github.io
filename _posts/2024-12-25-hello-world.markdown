---
layout: post
title:  "How to create a site using Jekyll running in a container and host the site in Github Pages"
date:   2024-12-25
categories: blog setup
---
This blog is created in [Jekyll](https://jekyllrb.com/), and hosted in Github Pages. The setup is as simple as possible and is limited to the [versions of the plugins](https://pages.github.com/versions/) that are included in the [github-pages](https://rubygems.org/gems/github-pages/versions/228) gem.<!--end_excerpt-->

When the files are commited to my github repo the site is automatically built and deployed to Github Pages.

I wanted to test the site locally, but I didn't want to install all the prerequisited for Jekyll, like Ruby. So instead I used Docker to create, build and test the site using the [jekyll/jekyll](https://hub.docker.com/r/jekyll/jekyll/) image.

Below are the steps involved when creating a site in Jekyll running in a container and test locally.

# Prerequisites 
- First get Docker up and running, and download the [jekyll](https://hub.docker.com/r/jekyll/jekyll/) image.
- Create a new repo in Github that will contain your Github Pages site, and clone it locally.
- Navigate to the folder where the repo is, and run this command to create a new Jekyll site in this folder.

```bash
docker run --rm --volume="$(PWD):/srv/jekyll" -it jekyll/jekyll sh -c "chown -R jekyll /usr/gem/ && jekyll new ."
```
- Create a `Gemfile` in the repo with the following content:

```ruby
source "https://rubygems.org"

gem "github-pages", "~> 232", group: :jekyll_plugins
```
- Update the `_config.yml` file and add the following:
```ruby
theme: minima

markdown: GFM

plugins:
  - jekyll-sitemap
```
This changes the default markdown processor to GFM, and explicitly tells Jekyll to use the `jekyll-sitemap` plugin, which for some reason is not enabled by default (like most other plugins that comes with the github-pages gem is).
# Serving the site locally
You can now use the following command to build and serve the site locally on `http://localhost:4000`.
```bash
docker run --rm --volume="$(PWD):/srv/jekyll" --publish 4000:4000 -it jekyll/jekyll sh -c "chown -R jekyll /usr/gem/ && bundle install && bundle exec jekyll serve --watch --force_polling --host=0.0.0.0"
```
- `--host=0.0.0.0` - needed, otherwise it will serve at 127.0.0.1, which is not available outside of the container.
- `--force_polling` - needed when `--watch` is enabled, because for some reason the file change events made locally are not propagated to the container. This allows us to automatically rebuild the site if we make changes. 

