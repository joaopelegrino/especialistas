What's up engineers? Indie Devdan here.
Welcome to an Agentic Coding devlog.
Let's start with the facts. The Claw 4.5
Sonnet release speaks for itself. It's a
step change improvement that has clearly
been trained for a gentic tool use for a
gentic coding. The model itself is
powerful, but when you take the model
and you put it in the right agent
architecture, when you put it inside
clawed code, this is where we get the
best agentic coding tool by far, bar
none. Codeci, Gemini CLI, they're
nowhere near as close as you think they
are. If you don't believe me, that's
fine. I'm going to show you right now.
And I challenge you to try to replicate
just half of what you're going to see in
this video with one of those tools.
Spoiler alert, you won't be able to.
So, what are we agent coding today?
We're going to solve two problems. One
in the loop on my device right here and
the other on my dedicated agent
environment. What are we doing exactly?
The clawed code SDK has been migrated to
the clawed agent SDK. So I need to
update one of my code bases to deprecate
the old way and to use the new updated
syntax and a couple of different changes
here. So while we're migrating on my
device, we're going to hand off some
work to my agents in their dedicated
device. We're going to have them build
out some prototypes of the real time
agents with the OpenAI tooling. So let's
hand off this prototyping task to our
agents right now. Cloud code in YOLO
mode here. Slash AFK agents. We have a
reusable MCP server prompt. I am handing
off work to my agents. I'm going AFK. I
need to pass in a couple variables here,
right? Prompt, ADW name, and
documentation if we need it. Accomplish
these three tasks. We have our three
agents that we want to get built in
three separate scripts. Be sure to
quickly test to make sure they work. So
we have a little closed loop structure
here, a validation command inside of the
highle prompt. And then I have my
specific ADW plan build ship. Then we're
passing in some documentation. This is
the exact docs that you just saw. And
just so you can see this, this is my
agent device. And if I open up code
here, when I kick this off, you're going
to see this agent device. You're going
to see this job get picked up. The agent
device just picked this up. And now I
have a fleet of agents on this device
that's going to handle this job. All
right. So I'm going to throw that in the
background. We're going to sleep every
60 seconds. Check in on the job. See how
it's performing. All right. So let's
open up cursor here. This is a private
proprietary codebase. But you can see
here we have applications and we have
eight apps. Let's fire up a cloud code
instance. I'm going to use MCP JSON
firecrawl. This is my cloud code sonnet
and yolo mode shorthand. Right away the
first thing I do I always turn thinking
mode on. There's no reason not to use
more compute. I've done this a million
times and so have you. And so we've
encoded this engineering workflow into a
reusable custom slash command slashcout
plan build. Very simple inputs here.
User prompt and documentation URLs. We
can start with our documentation. Grab
the URL. Throw that in the docs. Migrate
to the cloud agent SDK. As I write these
prompts at a very high level, I like to
look through the exact work that I'm
going to have my agents do. As you
practice walking through and adopting
your agents perspective, thinking
through what they're going to see,
you're going to find things that they
will likely miss. Sonnet 4.5 will have
no problem with a lot of this, but I
want to explicitly mention the system
prompt is no longer the default. If
you're using this SDK, you need to
explicitly use this new syntax.
Highlight this just specific section.
Pay close attention to the section to
make sure our update to the new syntax.
And that's it. So scout, plan, build.
What does this workflow do? Let's kick
it off and understand exactly what's
going on here. In the beginning, I
mentioned there are things that these
other agentic coding tools cannot do.
Let me show you exactly what I mean. So
here we have a wellthoughtout,
well-built, reusable agentic prompt.
This is a three-step workflow. Let me
just go ahead and collapse everything so
we can see this at a very high level.
Purpose, variables, instructions,
workflow, report. We first scout the
codebase for files. We then plan what
needs to be done and then we build. Why
do we have this additional scout step?
If you take a look at our agent
execution right now, you see something
really interesting. The first thing
that's happening is we're running/cout.
So we're using one of the brand new
features out of cloud code. You can run
custom slash commands inside of custom
slash commands. Let me say that another
way. You can compose your agentic
prompts. Okay, this is huge. Let's open
up the workflow and understand what
exactly that means. So check this out.
We have a simple three-step workflow.
Now there's a lot more details happening
here, right? You can see this is all we
pass in and all of a sudden our agent is
spinning up four sub aents to accomplish
work on our behalf. Let's go prompt by
prompt and understand how we're chaining
together more compute with cloud code 2
and cloud 4.5 sonnet. Let's dial into
our scout prompt, right? What's going on
with scout? search the codebase for
files needed to complete the task using
a fast token efficient agent. So what
we're doing here is delegating the
searching process from the plan step
into a scout step. If you've seen the
elite contacts engineering video, you
know that what we're doing here is using
the R&D framework. There are only two
ways to manage your context window. R&D
reduce and delegate. Here we're
offloading from the plan step and having
agents, four agents in parallel run
search for us. These are fast, cheap,
but still quality models that can do
tons of engineering work outside of your
primary agents window. So you can see
here sub agents have completed. You can
see we had Gemini light run. We had
codeex run from that scout search for
sub aents that then run their own agent.
We created this relevant files markdown
file. Now check this out, right? Our
agents have quickly searched through
exactly what needs to be changed. We
have the exact positioning of where we
need to update these files. We scaled up
our compute here to get multiple
perspectives, right? So, we didn't just
run another clawed agent that is, you
know, highly aligned with the other
clawed agents. We ran Gemini, we ran
Open Code, we ran Gemini again with the
flash preview, we ran codeex, right? And
we can even run ha coup in this workflow
if we want to. But so, you can see that
relevant files piece got created. We're
now moving to step two. Our planner read
all the relevant files that our scouts
put together and now it's scraping the
documentation that it needs. We want it
locally for all of our agents in our
pipeline moving forward. The scout
prompt is going to be inside of the
building specialized agents codebase. If
you're an Aentic Horizon member, you're
going to have access to this. This is
one of the extended lessons. There's no
reason to do this hands-on anymore.
There's no reason to even prompt in the
loop. But of course, I'm doing it here
so we can step through it piece by piece
together. Just to recap on this scout
workflow, this is something that I've
been playing with to offload context
from the planning step. You really want
your planner context window to be free
to really focus on getting the job done,
not just to look through files. Looking
through files isn't exactly planning,
right? Of course, they're building up
the context. That's important, but this
scout build plan three-step workflow has
been really, really powerful. So, I
wanted to share it with you here. We're
on step two now. During the planning,
you can see we're about to write our AI
docs right now. After a couple read
steps, writer agent is planning. The
planner isn't as novel. You've likely
seen these planner work steps before.
Here's our great prompt structure.
Here's our purpose, variables,
instructions, workflow, report. It's
pretty straightforward, right? We're
going to analyze, scrape, docs, design,
document the plan, generate, save, and
report. So, we should be saving and
reporting here pretty soon. When you
separate your prompts like this into
scout and to plan and to build into
whatever workflows that you need for
your work, you make it very easy for
both you, your team, and your agents to
understand what's happening. This
feature out of cloud code is incredible.
You can now chain custom/comands. That
means you can chain your agentic prompts
together. You can isolate and reuse even
more than before. And you can use this
syntax to just explicitly call these
things. and the agent will know exactly
what you want to do. All right, we have
this composite agentic prompt, but of
course we break it down. We have /cout
plan with docs and of course we have our
build that's going to run uh at the end.
Actually, that should be running right
now. Let's check it out. Yeah, there it
is. Nice. So, we should have our plan.
Let's see what our plan looks like. Here
we go. Typical plan. It's written up
everything that needs to happen. We are
agent coding. We're setting up the
reusable primitives of aenta coding.
these plans, these prompts, these
reusable and codable pieces of
knowledge, and we're making sure our
agents know how to accomplish tasks, and
we're deploying compute in a smart way,
right? We can't blow up our agents
context window. And think about this
workflow a little bit because there is a
problem with this workflow. You'll
notice here, one agent is going to run
all of these things back to back to
back. All right, we'll do a slashcontext
on our single agent that's doing all of
this work. And this is a big problem
that we completely sidestepped inside of
tactical agent coding which we'll talk
about more in just a little bit. But you
can see here our agent has read that
plan back in and now it is migrating to
the new clawed agent options. If we just
you know copy this and go to the docs
here you'll see this exactly this was
renamed and so our agent is just working
through all the fixes piece by piece.
This is not work you should be doing. In
fact, if you are prompting this work
back and forth, you should be investing
inside of your new prompting layer,
right? You need more prompts to scale up
your compute. And you want to make these
reusable. Prompt engineering is
critically important. It's just as
important as context engineering. Right?
With every agent you spin up, you have
to manage the core four context, model,
prompt, and now tools. You can see our
plan included tests inside this
codebase. We have eight custom agents,
right? Eight applications. Literally,
these are eight single individual
applications that our agent is updating
back to back to back making these
migrations. All right, so very powerful
stuff and I can guarantee you you're not
pushing your prompts far enough and they
can do a lot more for you than you think
they can. All right, let's see where our
agent is at. Perfect. Perfect. Perfect.
Critical system prompt migration.
Wonderful. So, it did catch this pen
system prompt needed to be replaced.
Phase five, phase six. Okay. Wow. Uh,
this is all complete. Tested pong agent.
Fantastic. So, I'm just going to go
ahead and say test a few more agents
that you don't need UI for. There's a
couple of these agents that require UI.
We're just going to skip those. And so,
I can guarantee you, by the way, our
agent dedicated device. It's already
finished its task. If I open this up and
yeah, so you can see here we had this
agent sleep in intervals of 60 seconds
and then just check the job continuously
check the current status of what agent
is running in this agent pipeline. You
can see there's the builder right here
and here's the shipper right here. In
separate 60-second interviews, there's
the status of this agentic job running
on my dedicated Asian device. This is
super super powerful. But let's just
recap what happened there, right? We ran
a single prompt scout plan build that
kicked off a aentic prompt. Now, why do
I keep saying agentic prompt? It's
because we have to add weight to how
capable these prompts are. We're not
just talking to a chat interface with a
couple of tools that runs for a little
bit. These are agents in the terminal.
These are agents that listen. There's
high adherence to the prompt with these
powerful models like clawed sauna. And
then to so push it even further and this
is why I say you know codec CLI, Gemini
CLI, they're not close. You can't be
close to the leader when you just copy
their feature set over and over. We have
powerful compute that runs especially
well inside of their customuilt agent
harness clawed code. And so this
powerful prompt runs three steps, right?
Right? We have a scouter where we're
looking for files that we need to
satisfy the user prompt. And we do this
because we want to pull out some of that
work that the planner is doing. Right
now, the planner, if we go into the plan
with docs, planner now has a couple very
powerful variables. It can just read
user prompt documentation urls passes
all the way into that. And then we have
the relevant files collection. And so
this was our uh scout output. It's not
just saying what files need to be
updated. It's actually going in and it's
saying what's the offset and how many
characters you need to read to get the
valuable information. And so we had
multiple agents take a swing at that. We
then have a couple static variables in
this prompt plan output and
documentation output. And then we have
our full-on instructions and our
workflow. And then finally, we have our
build. Build is a higher order prompt
where we pass a prompt into a prompt.
We've talked about this on the channel
in the past. Check out previous videos
to get caught up with this. And this is
our Scout workflow. This is the power of
a great agentic coding tool like cloud
code. You can't do this with these other
tools. So we ran this great prompt, a
simple high to mid-level prompt and all
this work is done for us agentically.
Documentation got read yada yada yada.
Now something important to call out
here. If I type /context, there's
something that I want to show you here.
Cloud code has added this autocompact
buffer feature. There's 22% of my
context window absolutely cooked. So
let's talk about that more in just a
second. What I wanted to get to
originally here is look at my messages.
51% context used by this agentic
workflow. Again, in tactical agentic
coding, we solve this problem completely
by using dedicated AI developer
workflows. We combined the old world of
raw code with the new world of agents.
We put them together and we isolate our
agents context window. Those are big
ideas we talk about inside of tactical
agent coding. There's a problem with
this, right? There are limits to this
and the limit is of course the context
window. our primary agent, even with our
delegation, still consumed some 50% of
our context window, right? Imagine if we
pushed this further. Imagine if we had a
larger codebase here that we had to work
through. Imagine if our our prompt was
even more detailed, which it certainly
could have been, right? This is a
massive limitation of single individual
agents. This is why we scale up to
outloop agentic systems. And we'll take
a look at the results from our outloop
system in just a second here. I just
want to mention that this chained
agentic prompt workflow it has limits.
The limit is your context window of your
agent and it's amplified and even more
restricted here by this autocompact
buffer coming out of the cloud code
tool. So there is a setting inside of
cloud code. If we open up a new instance
here, open up cloud code and then we
type /config. You can see we have
autocompact true with autocompact true.
If you type /context and let me just
shrink this so we can see a little bit
better. You can see we have autocompact.
22% of our context window is gone. Okay,
this is a huge detractor from cloud
code. But of course, the cloud code team
knows that this is a precious resource
for anyone using agents. And so you can
just turn this off. And so this is what
I do. So show compact or autocompact, I
just turn this off. If you turn this off
and then run context again, check this
out. We have that full 91%
free just like we want. The only thing
in here is our custom agents, a few
setup messages, and the built-in system
prompt system tools. All right, this is
what you want. You want a focused, clear
agent with as many tokens as you can
spend. Yeah, we were 14% away from
exploding our context here in our scout
plan build large agentic workflow,
right? And again, ADWs are the solution
for this. The context window is a hard
limit for us in the age of agents. We
have to respect this and we have to work
around it. And we always must observe
what our agent can see. What is your
agent's perspective? Does it have space?
Does it have tools? Does it have the
right model? Does it have the right core
for? These are the big ideas we have to
focus on. As a Gentic engineers, we need
to understand what our tools can do and
what their limitations are so that we
can understand what we can do and what
our limitations are. There is a direct
causal link between your ability to
control, build, and use agents and your
engineering output. Okay? If you don't
believe me, you're on the wrong channel.
What's next here? So, all four tested
agents are now working perfectly. You
can see here I have a specialized output
style. Cloud code 2.0. Fantastic
release. But something I noticed that I
didn't like at all is that they are hard
truncating a lot of the output from your
agent as it runs, right? They want to
keep it more clean and concise and
compact. Um, I understand that product
perspective, but I think maybe taking
Cloud Code in a little too broad of a
direction here, trying to make it the
tool for everyone, not just the tool for
engineers. We'll see how that
progresses. As an engineer, just like I
was saying, you want to be able to
understand exactly what your tool can do
and it helps to know that by just seeing
all the outputs. So, you can see here
I've designed an output style and I'll
go ahead and share this. You know, I
can't share this codebase. It's for
engineers inside of tactical agent
coding. But I will go ahead and share my
output style with you here. Observable
tools diffs TTS. So, this is a three
format output style. You get all three
of these diff reports. You get ordered
tool calls and you get audio task
summary. You can see here we got our
tools and since our last prompt was only
running, there's no diffs to report.
Link will be in the description if
you're interested in this cloud code
output style. If you're inside a Gentic
Horizon, you're going to see the updated
cloud agent SDK syntax here. Thanks to
this workflow that you saw in this
video, right, single prompt and this
work is now done. I'll do a little bit
more testing off screen just to make
sure everything looks good. Let's turn
to our outloop system. What happened
here? Our agent did everything. They
shipped this for us end to end. So,
let's see exactly what we got. I'm going
to copy this. Go ahead, hit new temp
clone cd open. Let's go ahead and check
this out in cursor. Let's see what our
agents built for us. We have our three
agents that we requested. And just for
clarity, let me just copy this. Throw
this in this file. And you can see
exactly what we prompted here, right?
So, we wanted three OpenAI agent SDKs.
one with a web search tool, the other
with a function tool. This is like a
custom tool. And then we wanted to check
out the OpenAI real time agent. And this
is something I'll do, by the way, when
I'm prompting agents and doing rapid
prototyping. I'll have the agent build
something simple, validate it, and then
build something more complex, validate
that, and continue upward. Right? Just
like with an engineer, right? A junior
engineer or an intern or even a
full-time senior principal engineer,
right? It's much easier to start with a
simple working thing than it is to skip
to something potentially complex. Let's
go and see how this worked though,
right? We have a couple files here.
Let's just go ahead and run them. UV
run. Let's run our basic agent with web
search. I'm not even going to look at
what's in that. Let's just run it. And
we need an openi API key. There's my
export command. Up. Run it again. And
we're running our agent with our web
search tool. There's a query. What are
the latest developments in AI agents
2025? There's a result. two total turns.
It looks like we have a decent lineup
here. Perfect. Yeah. So, the top news
announcement. This is something we can
easily lean on as ground truth cloud 4.5
sonnet. So, this is working great. We
have this web search tool inside of the
agent SDK. And you know, again, out the
loop on my dedicated agent device. I
just wrote a prompt and I said, "Set
this up for me. Teach me exactly how
this works." Right? And so, my agents
are doing that exactly. Let's go ahead
and see how far our agent pushed it.
Right? Did we get all the way to the
real-time voice? Let's see. So let's
copy this one. This is the um agent
function tools. You run
I assume it just has a couple simple
examples here of tool uses get user
info. So if I just copy this, I assume
this will be a local user tool. Yep,
that's exactly what's happening here.
And this is how you set up, you know,
open AI's agent SDK with a custom tool.
This is the one that I really wanted to
test. Let's see how this works. Full
audio will require additional libraries.
Okay, so this may not work. This is
easily the most complex one. There's our
response. Let's run this and let's see
how far we get here with our real time
API. Let's see what it's what's
happening here. Processing events real
time. So, it looks like there's more
work to be done here. I wonder if
there's some simple like string pass in
we can set up here. So, I'm just going
to spin up a quick clog instance here
and say set up a quick example of how.
Okay, so we have the AI docs in this
directory. I'm just going to link this
PC working. set up some quick audio
implementation. And so we're just going
to give this one shot. It requires
multiple prompts. We'll take this to the
back end and work on that. The big idea
here is with a single prompt, we can set
up entire environments and have our
agent execute inside of these
environments. Right? You saw it here,
right? Our agent fired off this job and
it went right to my dedicated agent
device right on my M4 Mac Mini. And you
can see we got live updates in 60-second
intervals from when we kicked this off.
And so if we pull down our actual agent
device, you can see top to bottom
everything that happened here, right?
There's the GitHub URL that got mounted.
There's all the documentation. There's
our args. I have a full log here. What I
want to show you here is an advantage
you can start building out right now for
your engineering work, for your team's
work, for your company's work. You
really want to have a dedicated agent
device that runs and builds and does
engineering work on your behalf. You
don't need to sit in the loop for every
single task that you're working on.
Right? If we just scroll down here, you
know, we can see we had our plan build.
Let me turn on regex. And we also had
our ship agent which did our actual git
push. Right? So you can just see line by
line, piece by piece inside of my agent
device. It completed work. It has output
files. I can trace the entire process
and it's all backed by a database. We go
into a ton of detail into how to build
your dedicated agent device, how to get
out the loop, and we do that inside of
tactical agent coding. This is my take
on how to build with agents to scale
beyond AI coding and vibe coding with
advanced engineering so powerful your
codebase runs itself. And I know simple
example, we just set up some proof of
concepts, passing in some documentation,
but I can guarantee you you can push
this a lot further. I push this a lot
further. I want you to have this massive
advantage here. A lot of engineers are
going to miss this. Okay? At first
glance, sitting here inside the loop
with your agent feels really good,
right? It feels like you're doing a lot
of work. But once you realize you can
set up better agents, more agents, and
then custom agents, I have this feeling
now when I'm prompting back and forth
with a single agent. Wow, I'm wasting
time. How can I scale this up? How can I
add more compute? How can I add more
agents? How can I build a custom agent
that does this better than any agent
does running inside the loop? That's
what tactical agent coding is all about.
All right, this is for engineers that
ship. And you know, by the way, I should
just stop and say this has been out for
one week and we have hundreds of
engineers inside of this course already.
Big shout out to everyone who's taken
Tactical Agentic Coding and that's
gotten value and started moving on the
new system that is more important to
build than anything. What if your
codebase could ship itself? That is the
big idea here. This is not for everyone.
This is not for beginners. The whole
idea here is really simple. We need to
let go of the old ways of engineering
and we need to master the new best tool
for engineering agents. Okay. And the
big big idea we talk about throughout
tactile agent coding is you want to
build the system that builds the system.
Okay. And what did we just do here in a
really kind of small microcasm example?
We used a system that is just on. We
passed a prompt to it and it did
arbitrary engineering work for us. Now,
you know, to be super clear, this
codebase did not exist before I ran this
prompt. This workflow created this
codebase, right? So, I could have I
could have prompted anything,
right? I really could have said and
asked for anything. This is a
differentiating advantage for engineers.
We're talking about asymmetric returns
on your engineering time. Okay, I wrote
two prompts and then I just talked to
you about what happened. You know, some
engineers that have taken tactical agent
coding, they're starting to build their
new layer around their codebase. They're
starting to build out and use the
tactics. Your engineering output is
going to be absolutely mind-boggling
once you start using the tactics of
agentic coding. Okay, so just a couple
things to mention here. This is about
building the system that builds the
system. It's about focusing on the
agentic portion, the agentic system in
your codebase and letting that do the
building for you. You know to be super
clear this starts with your reusable
prompts right you saw that here inside
of our building specialized agents
codebase you know another great feature
out of cloud code r backtick search I
can now say AFK right there's our AFK
prompt there and I can also look for our
scout right so there's that scout prompt
that we ran you know you can see here
this prompt was a perfect example of
building up just a little bit piece by
piece right we're composing prompts It's
a perfect example of if you invest in
the prompt, right, and you understand
what you can do with agentic prompts,
you can then have your system build your
application, right? And that's the big
idea here. And we go into serious
serious depth in tactical agentic
coding. We talk about scaling the core
four. We have the eight lesson core.
This is where we talk about the big
ideas. Build the system that builds the
system. And then we have agentic
horizon. So I mentioned this a couple
times. This is where you're going to
find the elite context engineering and
the agentic prompt engineering and of
course the building specialized agents
codebase. This is an additional product
you can buy inside of tactical agentic
coding. Right now we still have a couple
of deals running. By the time you see
this, it's probably going to be down to
9 or eight or something, but there's two
deals. If you're a principled AI coding
member, you have an additional deal. But
if you're not a principal a coding
member, and you'll know if you are. If
you're not, you're still good to go for
the early bird special. If you're not a
member, you will not have both
discounts. Let me just say that loud and
clear. There was some confusion on the
previous video. So, let me just be super
upfront about that. There are no tricks.
There are no gimmicks here. I am trying
to get the great engineers who invest in
themselves as soon as they see an
opportunity the opportunity to do that.
All right. Hop in this course. We talk
about building with agents and we scale
far beyond this back and forth prompting
that so many engineers think is oh so
powerful. and it is powerful, but it's
just the beginning. It truly is just the
beginning. So, this has been a short
agent coding session. I mean, I only ran
two real prompts, a couple follow-up
prompts just to clean up. I'm super
curious to see if we get a full
completion here out of the real-time
API. It looks like I got a great start.
Again, my agent just put this together
for me. 200, you know, 300, 500 lines of
code to start off this proof of concept.
All right, so this looks like an okay
starting point. Of course, an agent box
with no audio probably would not get far
on a task like this. So, I'll have to
push this forward, but this is
fantastic. Check out the links in the
description to get started with tactical
agent coding. Keep your eyes focused on
the most important tools. Don't get
caught up in the hype. Cloud 4.5 Sonnet
is in fact the best coding model in the
world. And on top of that, inside of
Cloud Code, it is the best agentic
coding model. It's the best agentic
model. You can set up long chains, long
workflows that run end toend work on
your behalf on your device and inside of
dedicated agent environments. These are
big ideas we're going to be talking
about on the channel. Make sure you're
subscribed. Make sure you're tuned in.
We have everything we need to get
massive value out of our agents. Now,
it's time to put the work in and build
powerful systems that operate on our
behalf. Thanks for watching. I'll see
you in the next one. Stay focused and
keep building.
