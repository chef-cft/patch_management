# Effective Patch Management with Chef

## Intro

Greetings! This repo contains a sample cookbook and guidance for building an effective patch management process.

## Objectives

What are our objectives in patching, e.g. why do we do this seemingly futile task? What business value do we provide? How does this task help the business? When we look at IT, there's really only a couple things it can do for a business; things that allow the business to move faster and things that reduce risk to the business. In the case of patching, we're really trying to reduce the risk to the business by minimizing the possible attack surfaces. According to most security firms, roughly 80% of all data breaches occurring the past few years would have been prevented if those businesses had an effective patching process.

Ok, cool, so our goal is to reduce risk; however, making low level code changes on basically everything in a relatively short time sounds pretty risky too, right? In the post DevOps world, we wouldn't patch. When new updates are available, they are shipped through the pipeline like every other change. Ephemeral nodes are provisioned, integration tests run, new OS images prepped, new infrastructure provisioned, etc.

I can read your mind at this point; "We aren't all start-ups, some of us still have a lot of legacy systems to manage." And you'd be totally correct. Almost all enterprises (and most smaller businesses) have legacy systems that are critical to the business and will be around for the forseeable future. Having said that, this doesn't mean that you can't have a well-understood, mostly automated patching process. So how do we reduce this risk without a ton of effort and expense. We automate.

## Process

As you'll see below, the names of the tools within a group may be different; however, they all function using similar patterns. These similarities are what allow us to build a standardized process regardless of platform. To start, we need a couple of core components.

* Repositories - Provides the content and content control
* Config. mgmt. tools - Controls the configuration of the client (I know... Mr. Obvious...). This is how we assign maintenance windows, reboot behaviors, etc.
* Orchestration - Tools that handle procedural tasks

We want this to be as automated as possible so everything should be set to run on a scheduled basis. The only time it requires manual intervention is when there's a patch we need to exclude. In the examples below, we'll configure the repositories to sync nightly and we'll configure the clients to check on Sunday mornings at 2AM. I can hear what you are thinking again, you're saying "We have a bunch of systems, we can't reboot all of them at once!" And you'd be right. Even if you don't have a large fleet, you still don't want to patch all the things at once.

In reality, you want at least one test system for each application, service, or role in your environment. Preferably, you want complete replicas of production (although smaller scale) for testing. Patches should be shipped and tested just like any other code change. Most enterprises have some process similar to Dev -> QA -> Stage -> Prod for shipping code changes so patching should follow that same pattern. Remember, the earlier we discover a problem, the easier and cheaper it is to resolve.

## Basic tools

### Repositories

Below are some notes on each major platform. The main thing to remember is the repository tool is the source for our patches. It's also the main control point for what's available in our environment. By default, we want to automatically synchronize with the vendor periodically. We then black list any patch or update that we can't use (or busted patches that break stuff).

Essentially, we want to create one or more local repositories for all of the available packages for each platform/distribution we want to support. The total number required will vary depending on your network topology, number of supported platforms/distributions, etc. Patching can be extremely network intensive. If you have a large number of systems or multiple systems across one or more WAN links, plan accordingly and don't DDoS yourself. I can't emphasize this enough, if you don't take load (network, OS, hypervisor, etc.) into account, you will cause severe, possibly even catastrophic outages for your business.

Now that the gloom and doom warnings are out of the way, let's look at some OS specific info.

#### Linux

Each Linux distribution has it's own repository system. For RHEL based systems, we use [Yum](https://wiki.centos.org/HowTos/CreateLocalMirror), and for Debian based systems, we use [Apt](https://help.ubuntu.com/community/AptGet/Offline/Repository).

> RHEL has some licensing implications for running local repositories. Talk to your Red Hat rep for more info.

#### MacOS

Until recently, macOS Server had a Software Update Services component. Some folks are using the new caching service but it's not quite the same.

#### Windows

Windows Server has an [Update Services](https://docs.microsoft.com/en-us/windows-server/administration/windows-server-update-services/get-started/windows-server-update-services-wsus) role. WSUS can provide local source for the majority of Microsoft's main products. WSUS also has a [replica mode](https://docs.microsoft.com/en-us/windows-server/administration/windows-server-update-services/manage/running-wsus-replica-mode) for supporting multiple physical locations or very large environments.

Windows users that are running newer versions of Server and Client can also take advantage of the [Branch Cache](https://docs.microsoft.com/en-us/windows-server/networking/branchcache/branchcache) features. This allows clients on a single subnet to share content and drastically reduce the WAN utilization without needing downstream servers.

### Configuration

I'm going to use [Chef](https://www.chef.io) for my examples (_full disclosure, I work at Chef_), but these principles will work with any configuration management platform. The main thing to keep in mind is the CM tool doesn't do the actual patching. This is a pretty common misconception. Yes, it's entirely possible to use a CM tool to deliver the actual patch payload and oversee the execution, but why would you want to do all that extra work? This is about making our lives better so let's use existing tools and functionality and use CM to control the operation.

### Orchestration

Orchestration means different things to different people. To me, orchestration is the process of managing activities in a controlled behavior. This is different from CM in that CM is about making a system or object act a certain way whereas orchestration is about doing multiple things in a certain order or taking action based on one or more inputs.

You will need an orchestration tool if you have any of the following needs (or similar needs):

* I need to reboot this system first, then that system for my app to work correctly.
* I want no more than 25% of my web servers to reboot at any given time.
* I want to make this DB server primary, then patch the secondary DB server.

If any of these sound familiar, you aren't alone. These are common problems in the enterprise; however, there's no common solution. With the magnitude of various applications, systems, and platforms out there, there's no way to provide prescriptive guidance for this topic. A lot of folks use a outside system as a clearing house for nodes to log their state then check the state with a cookbook on all the nodes to make decisions.

In regard to patching, if I have a group of nodes that has a specific boot order, I tend to stagger their patch windows so the first nodes patch and reboot, then the second group, and so on. I may also patch them in one window and leave them pending reboot, then reach out to them separately and reboot them in the required order.

## Technical Setup

Below are sample instructions for building the required components. These are not 100% production ready and only serve as examples on where to start. Each company has it's own flavor of doing things so it's not possible to account for all the variations.

### Server Side

First thing we need is to set up our repositories. We'll set up a basic mirror for CentOS 7 and Ubuntu 16.04, then set up a Windows WSUS Server.

#### APT Repository

```Ruby
# metadata.rb
```

```Ruby
# attributes/default.rb
```

```Ruby
# recipes/default.rb
package 'apt-mirror'
package 'apache2'

template '/etc/apt/mirror.list' do
  source 'mirror.list.erb'
  action :create
end

directory '/var/repo_mirror' do
  owner 'www-data'
  action :create
end

execute 'Sync Mirror' do
  command 'apt-mirror'
  action :run
end
```

#### Yum Repository

``` Ruby
# metadata.rb
depends 'yum'
```

``` Ruby
# attributes/default.rb
default['yum']['repos']['centos-base'] = 'http://mirror.centos.org/centos/7/os/x86_64'
default['yum']['repos']['centos-updates'] = 'http://mirror.centos.org/centos/7/updates/x86_64'
default['yum']['combined'] = false
```

``` Ruby
# recipes/default.rb
package 'createrepo'
package 'python-setuptools'
package 'httpd'

# https://github.com/ryanuber/pakrat
execute 'easy_install pakrat'

repos = ''
node['yum']['repos'].each do |name, baseurl|
  repos += "--name #{name} --baseurl #{baseurl} "
end

repos += '--combined ' if node['yum']['combined']

directory '/var/www/html/' do
  recursive true
end

#
#
# Convert to a cron resource to schedule nightly sync's
#
#########################################################
execute 'background pakrat repository sync' do
  cwd '/var/www/html/'
  command "pakrat #{repos} --repoversion $(date +%Y-%m-%d)"
  live_stream true
end
#########################################################
#
#
#
#

service 'httpd' do
  action [:start, :enable]
end
```

#### WSUS Server

```Ruby
# metadata.rb
depends 'wsus-server'
```

```Ruby
# attributes/default.rb
default['wsus_server']['setup']['content_dir']                  = "c:/wsus_content"
default['wsus_server']['configuration']['update_languages']             = ['en']
default['wsus_server']['configuration']['properties']['TargetingMode']  = 'Client'
default['wsus_server']['subscription']['automatic_synchronization']     = true
default['wsus_server']['subscription']['synchronization_per_day']       = '1'
default['wsus_server']['subscription']['synchronization_time']          = '22:00:00'
default['wsus_server']['subscription']['synchronize_categories']        = true
default['wsus_server']['subscription']['configure_timeout'] = 3600
default['wsus_server']['freeze']['name'] = "All Approved"
default['wsus_server']['subscription']['categories'] = ['Windows Server 2012 R2', 'Windows Server 2016']
default['wsus_server']['subscription']['classifications'] = ['Critical Updates', 'Definition Updates', 'Security Updates', 'Service Packs', 'Update Rollups', 'Updates', 'Upgrades']
```

```Ruby
# recipes/default.rb
powershell_script 'Configure Shell Memory' do
  action :nothing
  code 'Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 2048'
end.run_action(:run)

include_recipe 'wsus-server'
include_recipe 'wsus-server::freeze'

powershell_script 'Set WSUS App Pool max mem' do
  guard_interpreter :powershell_script
  code <<-EOH
  import-module webadministration
  Set-WebConfiguration "/system.applicationHost/applicationPools/add[@name='WsusPool']/recycling/periodicRestart/@privateMemory" -Value 4096000
  EOH
  not_if "import-module webadministration; if ($(Get-WebConfiguration \"/system.applicationHost/applicationPools/add[@name='WsusPool']/recycling/periodicRestart/@privateMemory\").value -eq 4096000){return $true}"
end
```

### Client Side

Now that we have repositories, let's configure our clients to talk to them.

#### CentOS Client

```Ruby
# metadata.rb
```

```Ruby
# attributes/default.rb
default['yum']['local_server'] = 'my-yum-repo-server.example.com'
```

```Ruby
# recipes/default.rb
::Dir.glob('/etc/yum.repos.d/*.repo').each do |repo|
  file repo do
    action :delete
    not_if { ::File.exist?('/etc/yum.repos.d/.chef_managed') }
  end
end

node['yum']['repos'].each do |name, _|
  yum_repository name do
    baseurl "http://#{node['yum']['local_server']}/#{name}/latest/"
    gpgcheck false
  end
end

cron 'Weekly patching maintenance window' do
  minute '0'
  hour '2'
  weekday '7'
  command 'yum upgrade -y'
  action :create
end
```

#### Ubuntu Client

```Ruby
# metadata.rb
```

```Ruby
# attributes/default.rb
```

```Ruby
# recipes/default.rb
```

#### Windows 2016 Client

```Ruby
# metadata.rb
depends 'wsus-client'
```

```Ruby
# attributes/default.rb

default['wsus_client']['wsus_server']                              = 'http://wsus-server:8530/'
default['wsus_client']['update_group']                             = 'My Server Group'
default['wsus_client']['automatic_update_behavior']                = :detect
default['wsus_client']['schedule_install_day']                     = :sunday
default['wsus_client']['schedule_install_time']                    = 2
default['wsus_client']['update']['handle_reboot']                  = true
```

```Ruby
# recipes/default.rb
include_recipe 'wsus-client::configure'
```

## Validation

Now the real question: "Did everything get patched?" How do we answer this question? Apt and Yum have no concept of reporting and the WSUS reports can get unwieldy in a hurry. Enter [Inspec](https://www.inspec.io). Inspec is an open source auditing framework that allows you to test for various compliance and configuration items including patches. Patching baselines exist for both [Linux](https://github.com/dev-sec/linux-patch-baseline) and [Windows](https://github.com/dev-sec/windows-patch-baseline). Inspec can run remotely and collect data on target nodes. You can have run Inspec via the [Audit Cookbook](https://supermarket.chef.io/cookbooks/audit) to have each node report compliance data to [Chef Automate](https://www.chef.io/automate/) for improved visibility and dashboards.

## Closing

Congratulations! If you are reading this, then you made it through a ton of information. Hopefully you found at least a couple nuggets that will help you. If you have any questions or feedback, please feel free to contact me: [@jamesmassardo](https://twitter.com/jamesmassardo)

Thanks to [@ncerny](https://twitter.com/ndcerny) and [@trevorghess](https://twitter.com/trevorghess) for their input and code samples.

## Helpful tips

Here are some tidbits that may help you.

* [WSUS memory limit](https://www.anyresearch.net/wsus-pool-reached-memory-limit/) event log error. You will almost 100% hit this at some point. This is a scaling config so the more clients you have, the more memory WSUS will need.
* Use attributes to feed required data (maint. window, patch time, reboot behavior, etc.) to the node. This allows you to have one main patching cookbook that get's applied to everything. You can deliver attributes different ways:
  * Environments
  * Roles
  * Role/wrapper cookbooks
* Remember we are using our CM system to manage the configs, not do the actual patching.
