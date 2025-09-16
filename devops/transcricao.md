
Welcome to Syntax!
Welcome to Syntax. Today we have another potluck for you. We had so many awesome questions that we wanted to take an
opportunity to yeah to answer those. And if you have questions for us for our potluck episodes, they happen once every
month usually. This time we get two and uh we answer your questions on the show here. So head on over to syntax.fm
and ask a question. There's a link right up there in the topnav. Uh we we're going to be covering all kinds of stuff
today from if you're moving from VS Code to something like cursor, how do you handle uh weird things that might
happen? Key bindings, keeping things in sync. Uh will Wom replace Docker?
Getting promotions? Uh is LLM puking out React? Are we done? Are we
Yeah. Is that it? Is this it? Or hosting mini apps inside of a larger app? My
name is Scott Jolinsky. I'm a developer from Denver and with me as always is Wes Boss. This show is presented by Sentry
Brought to you by [Sentry.io]
at centry.io s nt tr.io. Man, Sentry is just absolutely cooking
lately and there's almost too much stuff to keep up with. Whether that's their AI debugging tools, which simply rule.
Finding out exactly why things went wrong is really just the core message from Sentry. And it feels like their
tools are always improving this stuff just non-stop. They even are now doing things that like logs like we all need
logging and now instead of having to bring in another service you just do your logging directly in Sentry but it's
more than they connect to your traces so it's like part of your issues which is that's what
you want. You don't want have to piece it together yourself right it's not just a thing it's a thing that's connected and all this data
connecting uh really allows you to solve stuff in absolutely fast ways. There's a reason why like companies like Disney
Plus, like Disney Plus has a lot of people clicking uh play all the time.
They say, "I got to get Mickey Mouse. I got to get Minnie Mouse." And companies like Sentry make that possible
by really helping the engineers over there uh make that happen and fixing bugs and solving problems. So, check it
out. century.iosax. Sign up and get two months for free using the coupon code tasty treat, all
lowercase, all one word. Let's get into it. All right. So, let's get started with this part two of our potluck AON.
With me as always is West Boss. My name is Scott Tolinsky, of course. Wes, what's going on today, man? How you
feeling? Good, good. We're um back from the cottage right now. We're still going back up once more. It's in the middle
middle of August right now as we're recording, but we just got back from the cottage. It was awesome. It's getting
it's really dry up there right now. kind of scared about a couple forest fires out of raging, but I uh
I put like sprinkler systems in the cottage. For those who don't know, I we have a cottage up in northern Ontario
and I installed like almost an acre's worth of sprinkler systems and we pump water from the lake and just just go
nuts. So, I've been just soaking the grass cuz it's it's super dry and I don't want that catching on fire if
anything were to come close to it. We've been having crazy wildfires here in Colorado currently. So, yeah,
definitely a tense situation all around with that stuff. I I did see you got all dressed up today. What's the occasion
for busting out the tuxedo? Oh, no. The Canadian the Canadian tuxedo. No, this is this is actually a
new um salvage jacket. I've been wanting I've been wearing salvage denim for like 20 years and I absolutely love it.
Salvage denim is like a Japanese denim that like wears. Um it's like really blue when you get it and you get all kinds of cool fades and whatnot. It fits
perfectly to you. So, for many years, I've been wanting a salvage jacket, and I've never
I've never been able to like pull the trigger on one that I've liked. Uh, and finally, my wife is like, "You need to
to get one, you know, and I found this one. It's got little W's on the pocket. I researched it for years. I had it in
my like cart for for so long and finally I I pulled the trigger on it, and I'm uh
just trying to wear it a little bit more right now to get the get the fades going." Yeah, I I love that. I I I've
mentioned this before, but the very first day that I wore my first pair of uh salvage jeans, which are definitely
stiff and tight, at least mine were, I I went to the Big House, which is one of the largest, if not the largest,
football stadiums in the country, uh to watch a football game and I had to walk up and down like a 100 flights of stairs
and I like I had to like turn to the side and like walk down cuz I couldn't move my legs up and down the right way.
It was absolutely absurd. And then Michigan proceeded to lose to Minnesota
of all teams. And I was just like, what in the world is h Michigan doesn't lose to Minnesota? No, that doesn't happen.
So doubly bad day. I had to sit in the heat in salvage jeans. I couldn't walk up the stairs and we lost to Minnesota.
Yeah, I've I've been buying them with like a little bit of elastic in them the last couple years cuz just like having kids
and like really stiff pants is I used to wear the like 20 ounce. There's a there's this company called
Naked and Famous here in Canada and they make this they make a pair called the elephant and it's like it like cuts your
skin. Like I literally had blisters from wearing them previously and I I stopped wearing those cuz it's just like it's
hard to move around in them and especially when trying to like kneel down and tie up shoes eight times a day.
Yeah, it it's tough. Uh cool. Well, let's get into it. Let's talk about
potluck questions. This is where you have the questions, we bring the answers. Also, folks, we want to get Dr.
Courtney Tolinsky, my lovely wife and doctor of psychology, back on the show to talk about mental health stuff. If
you want to leave a question for the doctor, uh, you can do so on the potluck
form. Leave it anonymously. I mean, you could put your name on if you want to, but I I would encourage you to just
leave it anonymously and then we can get a bunch of questions for her so that way
next time she comes on the show, which will be once we get enough questions in here, that she can answer your your
mental health questions. Again, she's a doctor of psychology, so she can answer things about, you know, learning
disabilities. She can talk about all kinds of things related to mental health, learning disabilities, those
types of things. So, leave your questions in the potluck form and let's get into it with the first question
Moving from VS Code to Cursor without losing your shortcuts
today which is from DM. Hey guys, big fan of your work. Quick question. Have
you tried switching from VS Code to cursor? I'm running into weird issues with shortcuts. Wondering how or if
you've dealt with shortcut weirdness when switching over. Did you rebind everything manually or tweak some
settings? Appreciate any thoughts. I didn't have any weirdness. I don't know about you, Wes, but everything for me
just synced over fine. Uh, with the exception of some extensions that don't exist for what is it? Open VSIX or
whatever that is. Some extensions don't exist and those extensions therefore did not sync over. But other than that, it
honestly I I have VS Code Insiders, I have Curo, and I have Cursor all just
sitting there in my doc. And some days I open any one of the three because
they're always constantly being updated with new stuff and I'm trying them all out and I got to say it largely just is
a very fluid experience seamless between the three of them. Yeah, I had a couple issues. So what I
do is like because I switch between VS Code, Cursor Windsor for a while. Don't
have Kira yet. I was on vacation while it was open. Uh so I'm waiting for my my invite to that. What's the one from Tik
Tok again? Why am I I blanking? Oh, yeah. We we just heard about I don't know. I have not used that one.
Trey. Uh Trey, which is the the one from Bite Dance or Tik Tok. There's like there's a bazillion of them, right? And
I want to be able to like hit the ground running. So, what I did first of all about a year ago, I've been running the
sublime text key mapping for I don't know when did I switch from to VS Code
2017. like six six seven years I've been running the the Sublime Text keymap plugin and then I hated that because
whenever I told somebody what a keyboard shortcut was, it was not the right shortcut
because like nobody has that installed, you know. So what I finally did is I I scrapped that plugin and just relearned
the the default VS Code ones. Um and then I have in my dot files repo on
GitHub, I have all of my custom key mappings on there. And what I do is I simply just copy and paste or overwrite
that file from one to another. And I have to make sure that I keep it in sync. Um because
like if I change something in cursor, I want it to also reflect in in VS Code. So I try to keep them all in there. The
one thing that I lost in cursor was hitting command like one through six
will will bring you to tabs one through six. I love that. And it's in the browser. you know, if
you want to go to the first, second, third tab, I always hit command one, two, three. Um, so I had to remap all of
those. And then there was a couple that were kind of weird. Like, I'm pretty sure it's it's command L
in cursor opens up the There's one of them that it it opens up the chat window
that I was not not used to. I still haven't gotten a uh I still haven't gotten a shortcut for that. I
just do the command pal and type chat. Oh, yeah. That's honestly that's probably probably the move as well. But
yeah, I just I just had to remap it and explicitly set them. Even if you want it
to be the same as VS Code, just explicitly set them in your keybindings file and then they're they're going to be the same across all of them. There's
still like two or three that are a bit weird, but I just kind of deal with it and remember that's that's part for the
course when I'm switching between them so often. Yeah. Yeah, it is. For me, I I have set
up a number of keyboard shortcuts, but I I did them all so long ago that, you know, I'm not like I guess I'm not
changing that stuff that much right now. Maybe I should You know what? You know what I've been starting to do is installing
extensions on a project by project basis. That's such a good idea
instead of cuz like I I like eslint and prettier just like globally and then when and then there's like dino and bun
extensions and whatnot. So, what I'll do is I'll I'll install it and then disable it and then only enable it for that
project and then it goes into like the VS Code settings, whatever. Um, I have not found a good way to like sync
my installed extensions between all of them if anyone has has something for that cuz I would love that. Like I found
that like I had to reinstall a bunch in cursor that I that didn't make it over for whatever reason. Even though I don't
think cursor uses the open like there's basically VS code has their own marketplace and then there's like an
open VSIX which Scott said um and that's for anyone who's using like not VS code
the extensions have to be published on there as well like I have a I have a theme and I have to publish it to both.
kind of annoying, but Purser is like reverse engineering the VS Code
marketplace, which is apparently against terms of service, but uh
yeah, they they reverse engineered it. Man, I I'm stuck in a hole trying to get the syntax theme on Open VSX, whatever,
because it's like I've gotten everything approved, the organization is approved, whatever, and then you click publish and
it's just like project does not exist. And then you pan in the butt. You start the whole thing over again and
it's like it already exists. And I'm like, make up your dang mind. It either exists or it doesn't. And I can see it
there. And it's like I clearly am caught in some sort of database limbo state, but there's no like customer support
person I can reach out to. There's a GitHub issue that I filed like a month ago. So, I would love that theme in the
other editors if that could happen somehow. But it's Yeah, it's it's that type of project. So, that's a pain in
the butt. Daniel says, "I got promoted to senior at my previous job just a week
Should you bring up a senior promotion at a new job?
before an offer from a new company came through. Um, I did apply for a senior, but I was offered a mid-level, but the
salary of a mid-level was more than the senior in my previous job, so I went for it." Okay. So, he got promoted to senior
at his first job, got a new job as mid-level, which paid more than his
original senior one. Now, I'm at the job. I've been doing good and enjoying it. My probation is at the end of this
month. Do you think I should bring up the senior promotion or is it too early? I don't think my manager was aware that
I applied for senior. Interesting. So, there's there's always two camps here. Like, first of all, who
cares what you're called? But a lot of people are paid according to what their
actual name is. And that's why people care so much about this, right? like at like Netflix or whatever, they have L1,
L2, L3, and and your your salary is based on that. Um, so some people like
it just cuz it's it says I'm a senior, right? Um, some people like it because it means how much they pay. And some
people also like it because in your job like resume, you're applying for a job
and it says you're a senior, then you're mid-level, and then, you know, somebody who's just glancing at that stuff,
looking at a resume might be like, what happened here? you know, yeah, you got worse. So, should should
this person bring it up? I would probably wait until your your probation is over before before you do that. But I
I I don't know. I probably wouldn't do it just yet. Um, it sounds like you're making good money that you're happy
with. And if it's just the the name of it, I would probably wait six months or so and just really prove yourself.
Collect a whole bunch of like stories, right? Like I did X, Y, and Z. Here's what we did.
You have to be able to to prove this stuff. When it comes time to asking for
a a pay bump or a a bump in in what you're calling yourself, you got to sort of come to the table with like, I did X,
Y, and Z. We fixed all these things. This thing is faster. The client is much happier. And if you're only there for, I
don't know, a month or two, I doubt that you have a lot of that ammo yet. I think you take this up in a different way. I
think you do bring it up because this person says, "Should I bring up my the senior promotion?" I think you cut the
word promotion out of this. This is I don't think you need to be looking at this like a promotion. Here's the angle
I think you take. I think you take the ignorance angle as in, and I'm talking
about you talk to your direct manager in a casual way, not like, "Hey, I applied
for this. Where's my title?" Or, "I am listed as this. I thought I was going to be a senior. Can I get promoted? I think
you take the angle of, hey, just checking in. When I applied, I applied for the senior role and is accepted, but
I actually don't see that on my job title currently. Do you know what might have happened there? Like this is
casual. This is like, hey, me just checking in. What's going on there? And then because then they can come back and
say, "Oh, actually, you know, the way that we do things around here is that
this band is not listed as senior, but we know that you had that title. Maybe, you know, whatever. We we'll we'll keep
that in mind." Because I think you don't want to put any pressure on this. I think you kind of want to act like,
"Hey, not not it's not a big deal, but like, hey, I applied for senior. Just curious what happened there." To me,
that's something that makes sense if you do it earlier because you know that I'm just getting used to this. I just got
here. I'm getting used to the new work. What's going on here? To me, that makes sense as a way. And I think you can do
it in a way that is don't put any pressure on it. Don't make it into like a big deal. Come from a place of
curiosity. I think we should all be able to talk to our managers like this if if I'm being honest. I know some people
kind of walk on eggshells about like whether it is job titles or pay or anything like that. But I do think, you
know, having casual conversation about it isn't going to hurt anybody. You can even do it in person if that's a possibility. I don't think it needs to
be something that serious like you're just seeking answers. I'm just asking questions here, but you know, just
wanted to want to know what's going on there. But don't be like, "Hey, where's my promotion? I should have be promoted." That's not going to go well.
Relying on LLMs vs. learning database fundamentals
Uh, next question from EAD, but you can call me Rusty. I'm struggling a lot with SQL and database logic in general. I use
LLMs all the time and feel like a fraud most of the time. And for a nearly 1.5
year experienced web developer, I'm pretty weak on database logic. Bro, at 1.5 years, you should be pretty weak on
a lot of stuff. Is it normal to use LLMs to help me in stuff like this, or should
I study more to avoid being behind in backend and database logic? You know
what? Uh this is the stuff that's kind of important. It's important for security. It's important to make sure
your apps are running well. It's important to make sure that uh you know data is not being leaked or you don't
have any issues because you know the back end is that can write and access data and and those things to me are
higher stakes than oops a button is in the wrong place. So, if you're asking me and you're handling a lot of this stuff
and an LLM is spitting it out, you cannot put anything into your app that
you don't know what it's doing on the back end. You just straight up can't because
like we see hacks all the all the darn time because of unsecured uh rows or or
whatever unsecured tables. People performance too, right? If you don't know what an index is or you don't know
like a what the like relational keys and and how to relate items to another,
you can make a real mess. And that stuff sucks to have to to like change later.
You know, like I I have a database table named customer and a database table called user and in my head I know what
they are, but I'm so mad that they're named that because it makes no sense. I
I've had so many situations like that and I'm like yeah I could do migrations I could do that but like once you get
your data in a place or whatever and it's fairly mature man changing it all around sucks and so my suggestion here
is we are not in a post learning environment I would spend some major
time get your SQL get your database get your backend knowledge like locked down
from that perspective into like intermediate territory where you know the best practices, you know the entry
level stuff, you know the table stakes stuff, you know all of the the most important things about it before you
just let the LLM write the code for you in that regard. It's not worth it.
You're going to get yourself into trouble. So many of these questions that we're getting are like, do I do I learn this
anymore? You know, like what's the point? And like, man, bro, you are responsible.
Yeah, you're still responsible. Check out uh Aaron Francis. He's got a bunch of courses on different database stuff.
And even if you just like watch and like learn about databases and and how all of
this stuff works, it's going to be helpful just to know what to type into the box when you say, you know what, uh,
use this as a primary key or add an index for the email field or for
whatever reason. um or you be able to look at your your performance and because before you know it, you're going
to be having some some loop or like you're going to have some crazy database bill because of some garbage that was
written. So, expose a bunch of sensitive data and you're going to be responsible for that.
Like you said, learning is fun, bro. Like the a AI stuff is great that it can
make you so much more productive, but at the end of the day, it should be an extension of what you're doing. It shouldn't be like the expert because it
is often times not doing things in the best way. I mean at least like I know it
it can be very effective but especially it it would be like you have a lion and
no lion tamer, right? That lion is going to do whatever it wants.
Yeah. Been there. The lion's eating people, you know? So you you have to be a lion tamer to this thing still. And
and who Yeah. You got to know what it's doing for sure. Have some idea about what's going on. Question from Corey. I've always
Overcoming decision paralysis in programming
struggled with making decisions and unfortunately after being in this field for a while, I realize that programming
is basically a stream of constant choices and decisions. No kidding. It's like something new comes out every
single day. There's so everything is a tradeoff. Everything it's it depends and
it all changes. Do I do this? Do I do that? Every every three days. So, with the JavaScript ecosystem moving so quickly,
every decision is followed with a dreadful self monologue. Is this the right way to go, or am I shooting my
future self in the foot? Do you ever experience decision paralysis? If so, do you have any tips over not stressing
over FOMO and falling into the pit of decision paralysis? Yeah, my answer here
is this stuff doesn't move as quickly in production as it does on social media.
Yes. and and on this podcast is it's fun to to talk about all this type of stuff, but there's a reason why 10 years later
everyone's still mostly just using React um for the these types of things. And
just know that picking something that is a little bit more established and safe
over something that is new is often the better choice because these things they
they stop getting maintained. They get changed. They change their name. And like if I if I went for absolutely every
single brand new thing, you realize that they're especially if there's a business behind it, they're going to pivot into
an AI site builder at some point and you're going to be you're going to be out of luck. So just know that no one
ever got fired for choosing IBM is that's the saying, right? and and no one ever got fired for
choosing MySQL or or Postgress and and no one ever got fired for like there's so many people still using Express and
and they're totally fine with it and it's still a very popular choice even though I think we're at a point where
you should probably stop using Express there's a reason why a lot of people are still choosing it. A lot of the really
like like fancy stuff that people will like go on Twitter say this changes everything ultimately can get you into
trouble because the communities aren't mature. You end up hitting a edge case that hasn't been hit yet because there's
not enough people using it or it's in beta and you hit a bug. Then you got to sit and wait. Like as somebody who, you
know, really is early on a lot of stuff because that's my job. Man, it's a frustrating world. And like there's so
many times when I'm like, you know what? I want to get this done. I'm picking pocket base. I'm picking spelt and I'm
going to crank through something because it's easy and I know it's going to work and I'm very familiar with it. Not that pocket base is bad. Pocket base is
great, but like I just am, you know, it's not the latest and greatest new thing, but it it it works and it's great
and it's easy. So, like don't stress yourself out about this stuff. you know, get good at a set of
tools, be effective with them, and then when you feel like they are showing their age or cracking for whatever
reason, replace them here or there, and keep your ears open for what is new, and maybe give it a try in your spare time,
but don't let that kind of stuff slow you down. As far as decision paralysis goes, again, I think that's going to
come from establishing really like what are these things I'm very effective in and like locking them in. Like this is
the stack. When I used to work at an agency, we were cranking out sites um like every month. Like we had specific
stacks that we worked in for a reason because we were very good at that and we didn't have to decide all what are we
using for this. Uh no, we're going to you we're going to use Drupal. We're going to use the Omega theme. I think it
uses stylus. So, we're going to use stylus or or SAS. uh we're going to use this and that and these following Drupal
plugins and we're going to knock this thing out. And there was nothing like that productivity that you could get
from not having to think about all of those little pieces and you could just get to work. I think that's the one
thing and this is not related necessarily that AI has helped me with is that like it's easier for me just to
get to work because I'm not always thinking of these little tiny pieces that I do a 100red billion times every
single project. I'm just getting to work on the stuff that's important to me. There was a second question here that he
What to do when your code gets too messy
asked is what do you do when you're writing code and have that sudden realization that the code you have
written is starting to get too convoluted? been there, brother. That's the right
time to peel it back and to to refactor it. Don't just push it push it through because it's very unlikely that you are
going to come back and fix that and change it and you're going to build stuff on top of it. Um, so if things are
getting too convoluted or if you're doing things in a weird way, um, and and even talking to people about your
approach, like yesterday I was working on some Cloudflare durable object stuff
and I had a I had a problem and I I brought it into the Discord and then some guy was just like probably not the
right way to do that in the first place. And I was like, "Oh, that that I'm glad that you said that." You know, like the
the solution to my problem was not like I I had to fix some bug. The solution
was you're just not you're tackling this in the wrong way. You shouldn't be doing this. So, stop then peel it back as it's
frustrating to go back a little bit, but your future self will thank you. The AI I want is the one that says,
"Hey, dude. Just to let you know, this is not it. Uh what you're what you're doing right now, you think this is it.
you're making a big choice that you're going to uh regret in like another
commit, well, you're you're going to really regret it. So, commit frequently. Yeah.
Being able to jump back and like Yeah. Sometimes a a branch or sometimes uh a
pathway in your code is a learning opportunity and you could maybe
cherrypick some code and sometimes you just say uh let me just take some wooden boards
and board up that branch and say I'm not going back in that room. Uh that was the wrong idea and just moving on from that.
So this absolutely happens. Yeah. I need the little clippy in the corner of my text editor. It says it looks like
you're trying to to write some code that will address all situations. Would you like to just create a new file and and
duplicate a little bit of that code? You know, like sometimes I try to like make this amazing code that can can be used
in any situation where it's just like ah this would be better if I just duplicated these 20 lines and have a
different implementation. Mine needs to be, "Hey brother, I see that you are sidest
stepping the purposefully built way to do something because you think you have a novel use case. Let me tell you, your
use case not novel and you're making things harder on yourself." Uh, that's what I do. I'm always like, "Of course,
no one's doing this. I need to do this on my own." Um, yeah. Yeah. Oh, that's great.
Could Wasm replace Docker and Kubernetes?
Next question from Willie Mike. I've been seeing a lot more hots. What do you
think hots is here? hots around using like hots like people are like stoked about something.
Okay. I've never heard that. I've been seeing a lot more hots around using Wom
not for websites but for more of Docker Lambda replacement. Do you see
serverless standalone WOM computing as potentially an answer to easier, more
simple Kubernetes or Docker? Willie, I got no clue. Wes, what do you think
about this? I don't use this stuff that much. I'm going to be honest. But I hate Docker. So Web Assembly, the idea with with Wom
is that you can take a some compiled code like like that's
written in any language, right? Could be written in C, could be Rust. It's just compiled and you you convert it to
what's called a a Wom file, web assembly, right? And then you can run that code in something that run like in
the browser was was the first implementation of that, right? So if you want if you want to run ffmpeg or you
want to run some Python script or some you can even run PHP in the browser. We
often do that because there are purpose-built tools that are are not built in
JavaScript. Doesn't make sense to to write them in JavaScript or they're just not they're in other languages but you
still need to run them in a JavaScript environment. That's that's where we use WOM, right? Um now you can run WOM in in
in Node. Um, and it's nice because you just take this tidy little bundle very
much like a like a docker container. Uh, and you can you can run it in in
anywhere that you want. We use it on the syntax website to stitch together MP3s. We have ffmpeg
Wom running. So the question was, do you see serverless standalone WOM computing as potentially an answer to easier
Kubernetes Docker? Absolutely. Not in every single use case. You can't throw an entire Linux environment inside of a
um inside of a WOM container. Um but you can put a lot of purpose-built tools
that you simply just call from from JavaScript and it works really well. I
think even the creator of Docker said that like Docker might not exist if if WOM was around. Um I I don't know that
it's going to totally replace it, but there are a lot of situations where I will reach for Wom rather than having to
try spin up a container in inside of Docker. That's cool. And also like what
I've been seeing a lot lately is now that we have web GPU hitting all the
browsers like one of the downsides to WM is often significantly slower than
running it native, right? like the ffmpeg implementation is is much slower and
also it's hard to do multi-threaded unless you get into to some some complex stuff. So now that we have web GPU,
you're seeing a lot of tools that are now built that will run on on metal,
especially like like AI LLM models and whatnot running in the browser. So where sometimes you used to reach for WOM, now
there's there's often stuff that has been built and and can run on the right on the GPU of of your computer and that
might that might even be faster. It's all very interesting to me, just not stuff I deal with in Right. Yeah. or
stuff I hope to not deal in. I'll say that. Um yeah, you know what's one one interesting use
of Wom is um Shiki. So Shiki is a code highlighter. Shiki uses web assembly
because its syntax highlighting engine is built on top of onura a reax library
written in C and it's used by VS code's textmate grammar system. So like in
order to split up like you have some HTML and in order to split that up into like attributes and tag name and and and
angle brackets and and all that stuff. What VS Code uses is a huge reax library
and that in order for that to be fast as heck because it has to like every time you hit enter or type a character it has
to re redo it that's written in C. So if you want to run run that in a JavaScript environment you have to use WOM.
Interesting. Probably probably goofed up the um the thing here. That's it sounds Japanese.
How how would you pronounce that? An ani gura.
Let me send you the link. Uh, yes, that is Oni Garuma. There we go. I don't have that.
Organizing mini-apps in Express: monorepo, micro frontends, or something else?
Cool. All right. Next one from Ben Dean Ban. Hey, Scott, West, and CJ. CJ is not
here, Ben. Okay, we're tired of everybody being like, CJ, CJ, all the comments. CJ, CJ's so good.
CJ. Yeah, they were real quiet when I beat CJ in the last uh the last uh coding
video. So, I don't know. The CJ bots got turned off, which was great. On a major slump on those uh I got to
get get going, folks. If you haven't watching our our CSS battles, so you should tune those on there on on YouTube. Uh no, I'm just joking. We love
CJ, folks. He's the best. Hey, Scott West and CJ. I'm currently building a side project that's a collection of mini
app ideas to make my personal life easier. Its current form is an express app with templating and nunchucks, but
I'd like to practice my Angular skills more since it's the main stack for the front end at my new internship. I would
like to have a structure where each Angular app can be a standalone and only accessible via route in the Express app
and each page already built can stay in their respective routes. This idea also
keeps off state in each page of the express app including the angular apps.
How would I best organize what looks like to be a micro frontends approach?
Mono repos, same repos, separate apps with a reverse proxy. Thanks. This is
interesting. You could do this a number of ways and these mini apps. To me, I
think turning this into well, it depends on what you need here. In a big sense,
if you need individual versions for packages in these mini apps, as in these
mini apps have their own packages and these packages
are all versioned very specifically, then a mono repo makes sense. or even
like uh you when they when you have like um a linked repo. What do they call
that? Subreo. That's it. Yes. So you have like one folder of your git repo is a totally
you can get that if you just get in it inside of a folder inside of an existing git repo. Some people hate that, but I actually I
don't mind that and I I I've used that before successfully. That said, if these apps don't have that strict version
requirements and they're just like hacking together on some stuff and you're all using the same versions of everything and all these apps, you just
put it as folders in one repo. That's going to be the mo like the last thing
you want to do when you have like a for fun mini app thing where you can hack on
stuff and try something new and whatever. In my mind, if you bog that
down with a bunch of tooling around it, man, you can spend so much time on that tooling. And yeah, sure, you can set it
and forget it, but there are times when something, oo, this might be nice if I have this and then this and then this and next thing you know, you're
installing cross packages and it's all just a it inhibits you from working on
your mini apps and suddenly the mini app, you know, structure and everything is now what you your project is. So if
they are small apps that you know don't need self-contained versions and stuff like that just throw them all in uh
different folders and call it a day if you want to if you want to have that. To me that barrier to entry you can't beat
a small barrier to entry in this kind of stuff. This is what I do with my hot tips repo. So I have a huge repo full of
I don't know like probably 80 different apps that I've built over the you know just little demos to to actual big
things. What I have is I have vit in the root and then I have a plugin called vit dur v list directory contents and that's
a plugin that I built to allow you to click through the folders and see and then you click on one of them and it will will actually build it and that's
why that way you can have you can run typescript and all of this stuff without having to do any build step. Um but if I
do need a larger project inside of there I can always put a package json in that
subfolder and then that allows it to be its own thing. And that's I love that because like by default half of them
don't need their own package JSON, right? And I can share code between the two if I want to. But if there is a
situation where I do need its own package JSON, then I can go ahead and run that. That might be a good way.
Putting that in production is a little bit trickier because you have to build them all. Or I also have been tinkering
with building them on demand as as you click on one of them. I don't know if that's maybe not the best idea. I was
also thinking maybe Koolifi is a better approach here because maybe just you can
keep them all on a same monor repo if you want. That way you can share content between the two, but simply just throwing it up on
Koolifi and like back in the day I used to have a PHP server where I had just a folders full of stuff that I built and
you just drag a folder and put it on there. That's that's the kind of the dream with this type of stuff, but you
can also have the the whole build system. So maybe a Koolifi approach is is a bit better and then your express
app that you're talking about like authentication to like so that people can't access all of these different
applications that might work better as just like a global middleware uh maybe a
Cloudflare worker that sits in front of the entire domain name and checks the incoming request
to see if you have you can access it or you can even use something like Cloudflare access um where you you have
to log in with your your Gmail account or whatever before you it allows you to go forward um and access each of those
those values. I can't help but feel like this all seems overengineered for what it is though, you know,
and then it if it breaks then you don't feel like changing those those different
apps. That's a good question. I don't think I would build an express app that then
then routes everything for you because then you're getting into like your Angular stuff is going to need like a
build system, right? Yeah. And then then you're getting into turbo repo so
you don't build the things that haven't changed. That's what I'm talking about. The tooling. That's a bit of a pain. Project just becomes tooling. Yeah.
That's why like Yeah, that's why my whole like Vit thing that I built it it doesn't do backend though. It's just
simply client side stuff. But that's beautiful because I can simply just add
a folder. I can add a package JSON if I want and then I just have to surf to the URL and the whole thing will build on
demand. Next question from AI and more relevant. Uh as more developers use AI
Will AI lock us into React and make new frameworks irrelevant?
to write code and AI models improve. The framework and implementation details
become less relevant. New frameworks are built to solve problems that developers run into. But these problems become
abstracted away by AI. More code on the internet will be written by AI. It's
heavily tilted towards React, which will lead to there being mostly old React
code that current models are trained on and implemented into the new code written by AI. New improved coding
paradigms and code for frameworks better than React will decrease and new AI models will be trained on older React
code and older models. So the the question is like is this just churning out a bunch of React code and like is
that it? Like what is the point even to creating new new frameworks when like
the reason why we switch frameworks is cuz like developer experience and and performance and whatnot and if you can
just tell the AI model to do something is there anything there? So, I've gotten
this question a lot where people just seem a little bit like apathetic about
things getting better, you know, like we we've arrived. This is this is all that's going to be and we're just going
to just spit out a whole bunch of React code and and whatnot. So, I've said this many times on this podcast. As soon as
something becomes table stakes, the bar is going to be raised. Meaning that now
that these LLMs can churn out a CRUD app with a React interface that saves to a
database, we're not done. That's that's not it. Anybody can make a CRUD app that
saves to a database and logs in and whatnot. So that's table stakes. Now the bar is raised and and everything now
needs to get better, right? I'll I'll give you one example not from this is just how technology works. One example
not from LLMs is like search back in the day and search in WordPress was simply
just a like SQL query, right? You want to search your entire website. It looks
through uh your titles and it looks through the body of your content with a SQL query where it looks for that word
somewhere inside of that. Right? And that was search for for a very very long
time. But now that that was table stakes, it's so easy to do. Now we want
more. We want embeddings. We want uh to search inside of photos. We want
algorithms that are based on our taste. You know, I want to search and I want it to show me things that I want, not just
the same search result for everyone. We want similarity to things. We want to search want to be able to upload a photo
and search it. Like I get mad now. Yes. when I I can't like I wanted to find a photo on Flickr the other day and I was
like how do you search by a photo on Flickr? They don't have that. You know what an old website.
So that's so accurate to how I search now. Yeah. Jeez. A single oneline SQL query is now
this massive thing that is like it's backend, it's frontend code, it's database, it's indexing, it's embedding,
it's comparing, it's it's custom algorithms. technology gets better, everything gets better, and users are
going to expect more. So, that that was my first thing. I I wrote a whole bunch of stuff here because I thought that this was was a really interesting one.
The second thing here is that the apps that stand out are the ones where developers are rethinking how to do
things and the using cutting edge APIs. They're creating joyful experiences. Right? We can all turn out a shad CNN
CRUD app that looks like versal.com now. That's that's not a problem for anybody
to do. And and to a point where people are are getting tired of of that
experience. So the good websites now are people that are are, oh, this is fast.
This is local first. This is oh, you're using a whole bunch of new CSS. You're using a CSS anchor API. Oh, wow. You're
using all these new browser APIs. That's the stuff that's that's going to stand out. And that stuff is hard because
that's new. Uh, ask an LLM to to write you a whole bunch of um CSS that was
released 2 months ago. It's not going to do a great job. It'll probably get better as you can give it docs and
specifications and things like that. But the people who are still learning, this is the second time we've said this on
this podcast, you should still learn. You know, you're not you still have to
work past that. So that's good. And then my third thing here is that some cases we just don't need to spend time on
these things. Um at some point the LMS are going to get very good at some things and we simply will just not need
to worry about spending time on those things. There are lots of other problems in this world that we can solve with
technology. And I don't think that you're going to be bored. I've been trying to um come up with just how I
feel about some of this stuff in regards to the same thing. where like the AI has enabled people who don't know what
they're doing to push out stuff that is not going to be good experiences. And so
like for instance, I just saw on Twitter somebody being like, I really love this
blur effect. How can I do this in React? And then somebody responds, here's a
React package to sol to give you a blur effect. It's like, brother, it is a one
line of CSS. you were installing a React package for one line of CSS. And so the
bar needs to be like those are the people you're competing with because
that is not indicative like a a React package for one line of CSS even though that's not what it's doing. It's
probably doing some JavaScript in there. Either way, like that's not going to in itself make their app bad, but it's
indicative of a bad app because if that is one thing in an app, then there
there's going to be a lot more. So, like, yes, we need to focus on better experiences, faster apps, faster apps.
Absolutely. I mean, there's a reason why people say the web apps are not as good as the native apps. And some of that is
APIs available in Safari. And some of it is just straight up bad programming. Uh
low FPS, uh data that's taking too long to get into the device. React functions
that are running anytime something way up here changes for no reason whatsoever because people don't understand how it
works. So we need to definitely focus on better experiences uh overall whether
that is joyful, whether that is UI, whether that is animations and tasteful
and very specific ways to give context, but just speed, reliability, those
things, that is what a good programmer is going to produce. Yes, I agree. And I also think that
people are working on frameworks right now that are going to be tailored so that LLMs are good at writing them. The
LLMs are very good at writing JSX. They're very good at writing Tailwind code. And if people look at at how these
like what these LLMs are good at, they take a step back and say, "Okay, how do we now write a JavaScript framework that
an LLM will be very good at generating code for, at not making a mess out of it, you know, like it's very all all of
the things that the LLM are good at. What if you made a framework that was was targeted towards that?" Obviously
good for the developer as well to be able to to go through it, but what if the LM didn't make a mess and and
whatnot? I think that we'll probably start seeing that and and there people are trying to figure out like part of
that is like docs are super important right now and and part of that is going to be supplying the LLM with what it
needs to be able to figure out how to change things. So, I'm I'm kind of excited about what that will look like
in the next little bit. Yeah, totally. For sure. Next is the part of the show where we talk about
Sick Picks + Shameless Plugs
sick picks and shameless plugs. These are the things that we've been liking, enjoying using any of this stuff. I'm
going to pick something that I have sick picked at least twice now, but we've been doing this show since 2017, so I'm
allowed to do that. And I bust this thing out every once in a while, and
when I do, I'm always blown away just by how freaking dope it is. The Nimbot is
this little thermal printer that prints onto labels and it connects via
Bluetooth. And man, it is this little thing. It's It's little the labels come
on a thing. They're super cheap. You you go on your phone, you connect via Bluetooth, you type in what you want,
you add images or whatever, you click go, and it prints you off a dang little label. And yeah. Oh, did you put a label
on your Nimbot? You named it. Nice. Yeah. Well, we um we bought a whole bunch of the like you can go on
AliExpress and buy like different kinds of labels because it's thermal, right? And uh you can label like you can buy
kitty cat ones or clear ones. It's it's pretty good. It's thermal and and so therefore you're
not buying ink for this thing, right? It doesn't run out. The only thing you would have to buy is labels. And that is
super cheap and like man, it recharges. The app is great. I just can't believe
I've had this thing now for a while and it just still rules anytime I need to
label. Like I was labeling some stuff in my kids' room and it was just like, man, I love this thing. I I like this so
much. It rules. It It It's been so reliable for me. So, the Nimbot is going to be my pick. I have a funny uh
labeling story, Wes. Would you like to hear it? Yes. Okay. I worked at Target when I was 16
to when I went to college pretty much. Uh Target was a well-paying job in my city. U it was like one of the better
paying jobs. We just got in the Target, brand new Target. And uh I got the job. I was on the sales floor and I was
really good at my job, you know? I don't know why. The ADHD and the spatial stuff. I was just really good at the
job. So I was very wellliked by all of my bosses. But I had a number of I had a
number of like chaotic things I was doing behind the scenes for my own enjoyment. And one of which was naming
the walkie-talkies. Everybody had a walkie-talkie. And they had a label maker in the back room. So if you forgot
your name tag, you could print out a new name tag for the day. And I just started coming up with like every day of the
week I would come up with a name like you know like Steve and I'd print it out and then I'd put it on the walkie-talkie
because the walkie-talkies all just had numbers and next thing you know all the walkie-talkies got names. They're all
named different stuff and and the staff members were always like like people
were joking around about it. People love the names. And then they had to like send out a a a mailer that was like
please whoever is naming the walkie talkies we need you to stop doing that. like that is like that is we need you to
stop. But the best part is is they couldn't take away the label maker cuz we needed it
at the same time. There was no cameras or anything where I was doing it. So I just didn't stop. And they were getting
so angry. I did this for years and I never got caught. And I would wait a couple weeks and they, you know, died
down. They'd take them all off and then I'd put another one on. And man, you could tell it was pissing off
uh some of the the higherups there. No one had ever suspected it was the employee. They all like uh doing
something. So, it was so nonheartful. And at the same time, I was just like anytime we got a message about it, I was
just in tears by myself. Uh just being like, "Oh, this is so good. They're never going to catch me. They're never
going to catch me." I I love my my Nimbot as well. The only weird thing is
that it doesn't you can't like print it as long as you want. Like we have like a Brother one with like the keypad on it and I hate that cuz like
I hate typing. I want to type on my phone or like you can you can also emojis like like down. Yeah, you get emojis or
you can often what we'll do is we'll like my kid we we sort our kids like toys into boxes and we have like a
Minecraft box and then what we'll do is I'll just go on Google find the Minecraft logo bring it into the app and
then it'll like it'll figure out how to print it black and white and then you can put the actual logo on the uh the
label. It's it's just it's such a good thing. I want to get the bigger one.
Yeah. Yeah. You the whole text editors is amazing. And you there's also people have hacked them. You can use canvas uh
to print to them now with the web Bluetooth API. I didn't know that. It's a wild world. I kind of want to get
the bigger one cuz like this I got the Well, they have like a wide one, right? That's like maybe two and a half inches
wide. Interesting. And they're they're so cheap. Like this this one is 24 Canadian. Probably
probably like 15 or 20. Oh, you got tariffs now. Americans probably 1999. 1999.
Oh man, what a world. How much is that in Canadian? Man, stuff is cheaper in
Canada than it is in the States. We've arrived. I'm going to have to bust out my bust out my loonies,
man. Yeah, you got to come. We For my whole life, we've been driving over the border to buy beer and clothes and
Target and we would ship stuff. We have a mailbox in the States we would ship stuff to. The tables have turned, but
they have a bigger one. I kind of want to get it. 37 bucks. And like cuz I I put labels on everything. I just cannot
live my life without having labels. You just My son was just having such a hard time ignore like cleaning his room and like
putting things wherever they went. And I was just like, listen, if we name everything, you could see exactly what goes. My problem. I don't know where things go
unless there's a label. I have that problem when we do the dishwasher. And you know, like when we
use we have some plates where we use all of them. And then when I need to go, I don't know where they go. I need that
like um layout. You ever go to the store and they have like like somebody's merchandising and they they have like a
photo of where everything goes. I need that. See, I'm that's my domain where things go in the kitchen. That is my domain. So
I Yeah, that's my Yeah. Awesome. So I'll I'll pick that as well.
I'm a big fan of uh the Nimbot label printer. It's been fantastic. The only thing I'll tell you is it's not
good for kids like kids school stuff. Uh we still it comes they they Yeah. It like rubs off for whatever
reason. But like the the labels that we we buy with their names on it, they must be like printed on or something like
that because they go through the dishwasher no problem. But this stuff is they fade.
You've had a thermal receipt before. They fade. Whatever. Yeah. But for the most part, just like labeling anything,
they're not going to without a lot of rub. No. just just your regular stuff. I've had it like all my Hold on. Let Let
me see here. Like I've had Yes, I've had this for
like probably three years. Oh, they're cute. And they're
like micro USB, USB extension, and USB. So, I'm I'm showing a uh like a shoe
box, which is another sick pick of mine to organize all your cables. And like I go nuts with these.
I didn't have any I don't have any cute labels. That's it. All right, let's uh
shameless plug. What do we want to play? Do you have a sick pick? I'm I sick picked my Nimbot as well. I
think I I like that one. I love talking about how good that thing is. I know. I can't talk about it enough. Uh
shameless plug. We would love it, folks, if you were to Well, maybe just just go to YouTube and click subscribe, please.
Uh click, you know, the bell and all. People still click the bell. I haven't heard that being said as a thing in a
while, but either way, click subscribe, please. We do so much good stuff on YouTube beyond the podcast. So, uh you
want some more technical long deep dives and all kinds of topics. You want fun and games and just lots of laughs, we
got LOL's over there by the dozen. Uh check us out on YouTube/intaxfm
or just search syntax on YouTube. We should be uh numero uno there. Again,
we're doing all kinds of cool stuff. So, check us out. We would love it. We would absolutely love it if you hit
I always search for syntax, but I'm curious. Yeah, we are we are number one when we when you search it up. There's
another there's another channel, the perfect channel for survival game dinosaur enthusiasts called Syntac.
Nope. Don't beat us out. Nope. Cool. All right, thanks for tuning in. We'll catch you later. Peace.
