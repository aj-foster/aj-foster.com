---
title: Notes from Front-End Design Conference 2014
date: 2014-07-14
preview: July 10-11, 2014 in St. Petersburg, Florida
---

Please note that these are my personal notes that were not originally intended for public consumption. While I did edit them lightly for mechanics, all of the notes come directly as quotations or paraphrases of the speaker's own words. My personal commentary is set apart *in italics*.

Most of the context provided by the speakers at the beginning of their talks is missing from these notes. I chose to focus on the main points and memorable quotations.

The length of the notes for each talk has to do with how well my note-taking rhythm fell in phase with the speaker's rhythm; it is not a reflection of how interesting the talks were relative to each other.

---

### Human First Web Design

**Daniel Ryan** - [@dryan](https://twitter.com/dryan) - [Website](https://dryan.com/)

*Daniel Ryan worked as the Director of Front-end Development for the 2012 Barack Obama campaign. He related some of the things he learned throughout the campaign process.*

Design is not just aesthetics; design is a thoughtful process. We're all designers.

"Frictionless" is better than funneled. He shared a story about a Square fundraising app that failed because it asked too much, made the user work too hard, etc. The recipients read fundraising emails on their phones, but didn't complete the process because the mobile experience was poor.

Throughout the campaign, they used custom analytics and a bunch of A/B tests. You shouldn't just test: optimize. Have a strategy. Before you run a test, have a hypothesis about the results.

"Humans are more important than business goals."

"Being where users are is better than trying to get them where you want them to be."

The volunteer experience matters too. They created an iPad app to help volunteers get connected to nearby opportunities. It was backed by a Django app that tracked shifts.

"Being smarter is better than being perfect."

In the process of creating the application, they could have imported the existing spreadsheets of available shifts instead of having an awesome admin interface to input them manually. In general, you should start with a static design and justify every dynamic feature you add. Static sites don't break like dynamic sites do.

*Sidenote: Daniel is hiring python developers.*

*Daniel's position gave him the unique ability to rapidly test and iterate materials that were consumed by many users over a short period of time. In my opinion, his focus on maintaining simplicity for users, using data for design decisions, and putting humans at the center of the work, is wonderful. As a backend developer, I enjoy his policy of starting with static materials and justifying the need for dynamic content.*

---

### Animating the Web in a Post-Flash World

**Rachel Smith** - [@rachsmithtweets](https://twitter.com/rachsmithtweets) - [Website](http://rachsmith.com/)

*Rachel Smith is a front-end developer working for [Active Theory](http://activetheory.net/). She spoke about the decision process that occurs when including animations on client projects.*

We used to have many flash web sites with lots of motion and interaction; then came a trend of static web sites. Now we have transitional interfaces: how can we incorporate motion to make the experience better for our users?

We should all think about animating more. It helps us communicate a narrative. It gives the user cues about how to use the interface.

There's a lot of new stuff to sort through and learn. There's CSS, Canvas, SVG, WebGL.

CSS Animations vs. JavaScript frame-by-frame:

* When animating with CSS, the calculations are handed off to a separate thread with the GPU. That means better performance. JS stuff happens on the main browser thread.
* The lack of a need for JavaScript is pretty cool.
* You don't have much control, though, over CSS animations.
* You *can* use JavaScript to control the CSS, though.

Canvas:

* You can paint complicated stuff on a Canvas without filling up the DOM.
* It can perform bitmap manipulations.
* Unfortunately, it isn't crawl-able for SEO purposes.
* It also isn't stateful, so you have to manually keep track of what it is doing with JavaScript.
* Canvas is good for a scene with a lot of things moving around. Examples: particle demonstrations and games.

SVG:

* Major pro: It's vector-based.
* It's crawl-able, because it works with real elements.
* You can animate defined paths.
* It is highly complex, though, which can hurt performance.
* Using SVG is good for scaling icons and animating along defined paths.

There are no strict rules concerning animation. You have to experiment with it. The two important goals are performance and purpose. If an animation doesn't serve your overall goal, it's useless.

Know your browsers, write efficient JavaScript, and know something about motion. Good JavaScript is key: watch memory and garbage collection, have efficient code, and perform event listening / handling wisely. She mentioned using JS object pools (arrays of objects that are recycled) so that garbage collection doesn't kick in and reduce performance / frame rate.

Libraries don't matter that much. They can help you do things faster, but if you don't understand the JavaScript, it won't turn out very well.

Watching motion graphic examples helps. Try taking examples not from the web, but from TV and video.

*I believe one of the most important takeaways from this talk is the idea that animation, as a tool, can add value to your user's experience. It is no longer an all (flash) or nothing (static) decision to make. Of course, the animations you use should have purpose. Rachel did a good job of giving us a feel for the circumstances in which each method (CSS and JS, Canvas, or SVG) would be effective. Now it's up to us to try it out and have some fun with it.*

---

### Thinking Modular CSS

**Drew Barontini** - [@drewbarontini](https://twitter.com/drewbarontini) - [Website](http://drewbarontini.com/)

*Drew Barontini is a front-end developer at [Code School](http://codeschool.com). As co-creator of [MVCSS](http://mvcss.github.io/), he shared about the thought process that goes behind CSS architecture, with MVCSS as an example.*

Front-End Development is a thing. Although HTML and CSS are easy to write, they are not easy to write well. They need to be modular. They need to be self-contained. When you write front-end code, think about modules, components, and patterns, instead of pages. Make solutions that are reusable.

Modular design divides a system into small parts. They are independent, and can be reused in different systems. Furthermore, small chunks are more maintainable. Each module has one job, and it is entirely encapsulated.

Example: a cell module *only* handles width limiting.

Positioning and layout are constant struggles with modular CSS. You have to abstract them outwards and apart from each other.

Some tenants of modular CSS:

* IDs are bad. Classes are good, because it flattens the layers of specificity.
* Naming conventions are important, regardless of what they actually are.
* You should have a process of constant evaluation.

Let's use MVCSS as an example:

* Strict naming convention, like BEM. Modifiers are alternate sets of styles. States are added with JavaScript (ex: an is-hover class). Then there's context (ex: a has-dropdown class sets position: relative). 
* Submodules are scoped to a parent module (ex: btn, btn-a, btn-b).
* Abstract structure: a navigation structure shouldn't care how it is positioned. You can abstract up to a grid module or something similar.
* Don't use [magic numbers](http://csswizardry.com/2012/11/code-smells-in-css/#magic-numbers).

Steps to take:

* Identify the patterns you need to work with. Some examples: rows, cells, wells, and grids. Look for common patterns we can use like cards and lists. Look for unique patterns, like Dribbble's color list. Use a [front-end audit](https://github.com/drewbarontini/front-end-audit) to outline the patterns.
* Define stuff by looking at the module's responsibility. That gives you its name.
* Build it.
* Combine the modules. This is the interesting part.
* Refine and refactor, over and over and over again. Don't be afraid to be specific and abstract it out as you build.
* Look for weaknesses: magic numbers, fixed widths on elements, unsetting styles, and repeating styles.

Always be evaluating.

*While the talk used MVCSS as an example, the point was to encourage careful thought about CSS architecture. MVCSS may seem like a strict, opinionated setup, but that's all the better reason to think through the problems it solves yourself. Drew effectively insists that front-end implementation stand on its own as a concern of your project.*

---

### The Right Tool for the Job: Designing in the Browser for Agencies

**Andi Graham** - [@andigrahambsd](https://twitter.com/andigrahambsd) - [Big Sea Profile](http://bigseadesign.com/team/andi-graham)

*Andi Graham leads the team at [Big Sea](http://bigseadesign.com/), a digital creative agency. She spoke about how designing in the browser affects the dynamics of client work.*

We aren't always able to communicate with clients well enough to maintain our vision. Designing in the browser can help with this.

Designing in the browser:

* Eliminates the redundancy of designing things twice (in Photoshop and for the browser).
* Allows you and the client to interact with the design.
* Allows you to make quick changes easily, especially when you use preprocessors.
* Makes the design actually work. You can move parts of the design into the final project.

What do you lose if you don't use Photoshop?

* You lose some of the aesthetic appeal that you can get from Photoshop.
* It is difficult to design in the browser if you don't have all of the content.
* HTML and CSS are not design tools.
* Clients can't necessarily see where things are headed along the way.

Some steps to take:

* Get on the same page with your client. This might involve a kickoff meeting, mood boards, etc. Do gut checks: show sites that might be similar to what the client wants. *Check out [Visage](http://visage.co/).*
* Style tiles are cool. All the cool kids do them. Maybe try out digital style guides, because Sass makes that easy.
* Understand the project's constraints. Designers might not be aware of the constraints, and that isn't good. You can leverage those constraints when you present (read: explain) your design to the client.
* Show your work. It's okay for the client to see how ugly the product is at the outset.
* When you show the client your work, help them give feedback. Give them bullet points of what to look at. Make sure your client knows to question things early on, for the sake of your time and their budget.
* As a designer, be involved in client meetings. Keep communication open. Never just send over a proof; make sure you are there to explain and have a conversation about the design.
* Don't be afraid of Photoshop. Visual problem-solving is hard when you are trying to write code.

*Designing in the browser can be a controversial topic, in my experience. The big takeaway that almost everyone can accept is that designing in the browser changes the dynamics of your project in a way that can improve communication with clients. I'm curious to see if a pseudo-implementation of this policy (i.e. design in Photoshop first internally, then walk the client through the implementation in the browser) might have some of the same benefits. The bottom line is, for me, more communication is always better.*

---

### I Have No Idea What I'm Doing

**Elyse Holladay** - [@elyseholladay](https://twitter.com/elyseholladay) - [Website](http://www.elyseholladay.com/)

*Elyse Holladay is a teacher, developer, and designer at [Maker Square](http://www.makersquare.com/). She spoke about addressing our fears and overcoming self-judgment.*

Sometimes, we focus on our "tigers": the things that scare us. That isn't what we should think about.

"Is being good at something the only measure of its worth?" Just because we aren't good at something doesn't mean we can't enjoy it; doesn't mean that it doesn't have value.

It's most important to learn what things we don't know. The dangerous situation is when we don't know that we don't. Note that we still feel bad about those things when we discover them. We shouldn't feel bad, though.

"We tend to judge others by the end product, and judge ourselves by the struggle we went through to get there."

Imposter syndrome is a thing. Everyone has it. Be lucky, set goals, work joyously, share your doubts... The biggest hurdle isn't ability, it's doubts. Be kind to yourself. Celebrate your wins. Help others.

*Elyse began with a story of someone who is running away from a tiger, reaches a cliff, and climbs part-way down some vines that hang there. There are tigers above and below her, but she takes time to eat and enjoy a strawberry hanging next to her. Part of the lesson is to not let our insecurities - the things we don't know - stop us from using and enjoying the things we do. I definitely agree with the notion that discovering what it is that we don't know, though frustrating, is extremely important.*

---

### How to Build Kickass E-Mails

**Kevin Mandeville** - [@kevingotbounce](https://twitter.com/kevingotbounce) - [Talk Resources](http://litmus.com/lp/frontendconf)

*Kevin Mandeville works for [Litmus](http://litmus.com/) designing HTML emails. He spoke about the crucial differences between designing emails and web pages, and how to get started.*

Email has progressed more slowly than the web due to client fragmentation. At the moment, mobile is in the lead in terms of the clients used to read emails. With that said, the important thing is to know your particular audience. Your demographics might be very different than the average. Email design requires you to choose which clients to support.

How to build emails:

* Email design is not web design. The first step is acceptance...
* Use tables, not divs. It's frustrating, but deal with it.
* Best single piece of advice: "<td> or GTFO (get to fixing Outlook)".
* Only apply styling to TDs. Exceptions: links, images, spans.
* Keep emails modular. 
* One-column design works best for emails. It also performs better analytics-wise.
* Maximum width of 600px.
* Never use margin, always use padding. 
* Use HTML attributes when possible (ex: height, width, bgcolor).
* CSS must be inline.
* Use <b>, not strong. Use px, not em or rem. Use full hex codes. Use align, not floats.
* Always align your <td>s.
* iOS needs a <span> to overwrite default link styling.

Single most misunderstood thing about email: responsive email is not supported everywhere. There's a difference between device support and application support (devices might have several email rendering engines available).

Single most overlooked thing: the images-off view. 43% of emails are viewed with images off. Never forget alt text.

Images should be display: block. Google caches images... And compresses them. You might not want to compress images before sending them. Don't use images for buttons. Use bulletproof buttons: see [buttons.cm](http://buttons.cm/).

Use preheader text for better (+30%) open rates. Reset styles can go in the header. If you wrap font face properties in a media tag, they will be ignored by Outlook.

*HTML email has become a point of contention in our community because of the unsemantic markup required. Yet, there is a need for individuals who can design and implement it. Unfortunately the stigma (that admittedly, I have helped to perpetuate) does not help the area to improve.*

---

### Boxes & Grids, Oh My

**Noah Stokes** - [@motherfuton](https://twitter.com/motherfuton) - [Actual Website](http://esbueno.noahstokes.com/)

*Noah Stokes is a designer / developer at [Bold](http://hellobold.com/) and a professional composer of tweets. He spoke about the notion that "responsive web design all looks the same" and what we can do about it.*

"The web was losing its soul... And I was blaming RWD."

The soul of a site is the intangible details of its design. While there is a trend towards flat design, that isn't an excuse for lazy design. Some of the problem lies in decreased budgets in the comp phase of design. Skill sets also play a role.

RWD is still young, so we rely on trends to become comfortable with it. There are a lot of talks about it, but people are still just now starting to get involved.

RWD isn't taking the soul out of design, the way we implement it is. So what can we do?

* Think outside of the box. It can be easy to look at a design and figure out how to implement it. We can get confused about how to implement "different" designs, and give up.
* Think about duplicating HTML for small pieces. Maybe you *should* use absolute and fixed positioning. Don't forget about JavaScript too.

It doesn't hurt to take a step back and let your subconscious work on it for a while.

Don't settle. Think outside of the box. Bring back the soul.

*After his original frustration, Noah came to a fair understanding of the dynamic between the responsive web and design. It is true that RWD is still a young area, and our way of thinking about it has yet to fully mature. Dealing with its unique problems just might require some less-than-semantic solutions, and that's okay. If the method adds value to your user's experience, that is what really matters.*

---

*The following are talks from day two.*

---

### Lessons from the Lemonade Stand

**Carl Smith** - [@carlsmith](https://twitter.com/carlsmith) - [Website](http://devianthippie.com/)

*Carl Smith is the "advisor" of [nGen Works](http://www.ngenworks.com/). He spoke about the human side of work, and gave some advice about how to manage stress.*

* "Worrying about stress is worse than stress." Stress is like exercise; it's self-repairing if you don't worry about it.
* Sleep is not the enemy.
* Go outside. Go for walks.
* Play games. When you make up games and play them, you are cooperating, you are negotiating, you are competing.
* Smiles are the secret weapon for kids. They hava a big impact, and smiling is addictive.

*Carl related the story of his daughter's lemonade stand and what he learned from her entrepreneurial spirit. His note about stress is very important: it does happen, and it will repair itself if we allow it.*

---

### Intersecting Worlds of Web and Education: A Foray into the Digital Frontier

**Erica Walker** - [@ebwalker101](https://twitter.com/ebwalker101) - [Slides](http://goo.gl/YqJb5S)

*Erica Walker is a lecturer at Clemson University for graphic communications. She spoke about the differences and connection between formal and community education.*

What do we mean by community education? It's informal. This conference is the epitome of community education. It's about us, and our personal pursuit of education. The problem is that there are many, many places to go. How do you know where to go? We need to promote some sense of direction.

Both formal and community education could play nicely together. Formal education has dedicated class time, a set curriculum, and face-to-face interaction. However, formal education gives students no say in the curriculum, and it is expensive. Community education is available 24/7 and occurs on a self-directed basis. Still, the resources can be hard to sort through. 

How can we mix the two together? We need a balance.

*Erica touched upon an important issue: there is a large divide between formal education and the industry / community. There are opportunities for greater communication and collaboration between the two.*

---

### Styling Forms Semantically & Accessibly

**Amanda Cheung** - [@acacheung](https://twitter.com/acacheung) - [Website](http://acacheung.com/)

*Amanda does front-end work at [DockYard](http://dockyard.com/). She spoke about accessibility of forms on the web and demonstrated some of the common issues encountered by screen readers.*

Accessibility efforts assist people with visual, motor, auditory, and cognitive disabilities. The steps we take to improve accessibility can actually improve the user experience for everyone.

Some simple things: allow the use of tabs to move between inputs. Have related labels for inputs to increase the clickable area. Make sure all selection choices are visible when the list is expanded. Bonus points if the inputs are visually engaging and "on brand."

You can use abbreviation tags to help accessibility. If you don't want labels, hide the text in such a way that a screen reader can still see it.

Some known issues: There are issues with tabbing through checkboxes on Safari, and it is difficult to style select dropdowns correctly.

There are some new and exciting input types: telephone, web, email, date, time, and number inputs. Ranges and colors, and even datalists.

*Amanda's attention to accessibility is something we can all learn from. It helps that, in many cases, accessibility falls in line with semantic markup. There are [plenty of resources](http://a11yproject.com/) out there to level-up with accessibility.*

---

### Let's Be Brutally Honest About Operations and Pricing for Web Agencies

**Rob Harr** - [@robertharr](https://twitter.com/robertharr) - [Sparkbox](http://seesparkbox.com/)

*Rob Harr is the technical director at Sparkbox. He spoke about the day-to-day operations of an agency and gave advice based on his experience.*

Operations means "getting crap done." At Sparkbox, they use a micro-cash flow strategy: every Tuesday, they balance the accounts and do an outlook on the budget. In general, the best case scenario is that you have 6 months of runway if clients stop coming.

Your freedom is not free. Being good with your cash today will finance future business. Business forecasting is basically trying to predict the future. Don't rely on it. 

Options on how to price your work:

* Fixed pricing. They've seen mixed results with this.
* Hourly pricing. This is what they use.
* Value pricing, i.e. figure out what the value of the product to the client is, and charge that.

There is no right answer. Focus on adding value for your clients. Sparkbox does hourly pricing, and it works alright for them. The best way to price things is a continuous argument between business owners. They key thing is to focus on something that makes you money.

Initial engagement: users are bad at saying what they want, and software people don't know what to expect. Before jumping in, do some paid discovery: perform a short project to "date" your client. This kind of a project usually doesn't need as much approval from the client either.

Their rate: $165 per hour. They constantly review it and prototype it with new clients. They do something called collaborative pricing: share a google doc with the budget that the client can edit. There's a 20% deposit for safety. Weekly invoices help cash flow. 

They work for hire. As soon as a piece of software is written, the client owns it. This way there's no licensing, no liability.

Some good ideas:

* Know your terms. 
* Get a line of credit before you need it. 
* Get professional help. There are people who you can pay to help you with your business.
* Know your legal documents. Check out [msabundle.com](http://msabundle.com).
* Find some owner friends. Every business is going through similar struggles.
* Train your clients to think about your pricing model. For hourly pricing, the clients can see how much effort is being put into every piece of the project.
* Have difficult conversations.
* Decide as a team which parts of a project should be experimented with (ex. trying out new technologies).
* Track your time. Increase your rates. Find better clients. Clients don't grow with you.
* Plan for taxes all year long.
* Save your cash.

*Rob's experience at Sparkbox is one example of how to operate a business. His insistence that there is no right answer is probably the best business advice available.*

---

### Remote. Commit. Push

**Travis Miller** - [@travismillerweb](https://twitter.com/travismillerweb) - [Website](http://www.travismillerweb.com/)

*Travis Miller is a developer at SPARK who lives and works in the Bahamas. He spoke about the challenges of working remotely and how to survive with the tools available.*

**Remote**

It is difficult to work remotely while maintaining the feel of working in the office. Travis had to learn a lot: better communication, time management, client relations, creating content.

Seclusion was essential. He had to learn how to work with the limited tools that were available.

**Commit**

Committing is difficult. Nothing gets done unless you commit to learning something. Things like Grunt are exactly the kinds of tools you have to use while working remotely. If a computer can do it, let it. Sass is another good example: the code is maintainable, you build with change in mind, and it has a manageable architecture.

Working remotely depends on learning how to use the tools you already have. In his case, Google Drive allowed him to perform rapid prototyping and iterations on UX documents. He uses the collaboration tools in Drive to communicate with the client and perform revisions. Documents can link to each other, which allows you to keep a project's information together and keep a single folder of bookmarks for each project. Revision history, of course, is another important feature.

The point is, there are incredible tools already at your disposal. When you work remotely, you have to exploit these as much as possible. 

Communicating during development is already difficult; try doing it at a distance. Document things as you go to record the context of what you're working on. Your documentation is like Wilson from Castaway. Travis suggests using Evernote (and Evernote for Chrome). You can take screenshots of what you are working on and add a short description.

The tools you use become your team.

**Push**

Part of the push is to get into the habit of using these tools. Another part is changing your outlook to accept the way things are.

Wherever you are in the world, share what you've learned. Travis was able to help establish a web community back home in the Bahamas.

Travis was remote, but he was never alone. Commit to being better. Push yourself and the people around you.

*Travis's resolve is a big encouragement. Even for people who do not work remotely, the lessons Travis spoke about can improve the entire development experience.*

---

### No Control: Designing for the CMS-driven Web

**Andrew Norcross** - [@norcross](https://twitter.com/norcross) - [Website](http://andrewnorcross.com/)

*Andrew Norcross is a developer at Reactiv Studios, as well as a WordPress core contributor. He spoke about the challenges that arise during the design and implementation of CMS-driven sites.*

Norcross is not a designer; he can implement designs effectively though. Many times there is a gap between how something is designed, and how something is going to be used.

User-driven websites are becoming a much bigger part of the web today. There need to be additional design considerations made, but you don't necessarily know about them during the design phase. 

* Users are inexperienced. We often need to take a step back and realize that what we know is very unique to our line of work.
* Content focus is always changing. Examples: a blog post can change based on images, post formatting, videos, etc. The user can do all of those things without asking you, and they will find every edge case you didn't think of. Magazine layouts are extremely variable. These things make designing very difficult. 

It is worth your time as a designer to know how the content is going to be run (i.e. which CMS). Collaboration is extremely important: as a designer, you should make clear the goal of your design to the person who is gong to implement it. There's a good chance the implementer can make your life easier by presenting some of the tools available. Maybe keep a notes file or a written style guide to accompany the design.

*Norcross, as Dan calls him, knows well the difference between a design and its implementation. His suggestion about making a written style guide to accompany the design seems like an excellent idea, even for non-CMS based projects.*

---

### SMACSS Your Sass Up

**Mina Markham** - [@minamarkham](https://twitter.com/minamarkham) - [Slides](http://mina.is/speaking/smacss-sass/slides.pdf)

Sometimes you need to make quick demo sites. These projects are the reason Mina got into modular CSS. You can see Drew Brontini's talk for more about this. Mina likes to use SMACSS.

It's a philosophy, not a framework. You can pick and choose the parts you want.

You categorize your CSS: base, layout, modules, states, and themes. This talk focuses on modules, where the bulk of the code lies.

Sass helps the process in a number of ways:

* Namespacing with `&`. With Sass 3.3, you can use `&-` to add suffixes to your selectors.
* Nesting - but be aware of the inception rule. The `&` operator helps with this a little, but you probably shouldn't be nesting too deep regardless.
* `@extend` helps in some cases to limit the number of classes you have to add to any given element, especially when dealing with submodules. Note: don't extend between modules.
* Sass 3.4 has some new selector functions. That's one cool thing about Sass; it's constantly evolving.
* File structure. Sass partials and imports help you keep your modular code organized. This helps maintainability. Mina showed her way of organizing files.

Check out Mina.so/smacss for examples of how she works, and read the SMACSS book if you haven't checked it out yet.

*Mina's personal journey leading up to her talk is a big encouragement. She's a great example of what a healthy community can help to create.*

---

### Contextually Aware Web Design

**Matthew Carver** - [@matthew_carver](https://twitter.com/matthew_carver) - [Website](http://www.matthewcarver.com/)

*Matthew Carver is the technology director at [Big Spaceship](http://www.bigspaceship.com/). He spoke about creating sites that are fully aware of the context in which the user is viewing them.*

"Context is as important as content." Responsive web design is all about being contextually aware.

Contextual awareness uses JavaScript to adjust a user's experience based on available sensors. The expression within a media query is one example of a sensor.

Web design has historically been considered an observed medium, much like television. Contextual awareness comes from computing, and it does exist in the wild: Google uses your data to change your experience, and Apple has the M7 processor to utilize contextual information.

Four parts of the awareness:

* User: what do we know about the user? This can include accessibility and things like his/her data connection.
* Task: what is the user's goal? Maybe you can "clear the path" for that task.
* Environment: where and when is the interaction taking place?
* Technology: we focus on this a lot with responsive design. Beyond screen size, though, you also have to consider how the interactions are taking place (i.e. touch vs. pointer).

A contextual breakpoint is the point at which the context of the website has changed. For example, a coffee shop might want to change the visual centerpiece (picture of a drink) based on the time of day. The breakpoints in this case are morning, noon, and night.

Matt creates a global sensors JS object to contain all of the contextual breakpoints. Each breakpoint answers true-or-false questions like "is it morning?" That way, you can just say "if sensors.morning, do something." Even better, use a for loop to iterate through all of the available sensors and add a class to the HTML or body tag. From there you can use CSS to modify the front-end accordingly.

Check out nome.js (link unavailable) for a library of contextual awareness. It covers most everything that is available.

Level 4 media queries open up a lot of new possibilities. One example is the luminosity query: you can augment your CSS based on dim, normal, and washed states. There are also custom query methods that are usable via JS. Pointer defines the size of target area covered by the pointer device (coarse or fine). Hover defines whether it is possible for the user to hover. Finally, there are display quality queries: scan, resolution, and update frequency. 

iOS 8 seems to be built around contextual awareness. Physical information is making its way into the digital world. It's happening, and all it requires is thoughtfulness and imagination.

With all of that said, do consider the "creepiness factor" of the assumptions you are making about your user.

*The upcoming possibilities surrounding contextual awareness are quite exciting. Matthew did a good job of setting the tone for how the new sensors can be utilized.*

---

### Design Pattern Craftsmanship

**Jason Beaird** - [@jasongraphix](https://twitter.com/jasongraphix) - [Website](http://jasongraphix.com/)

*Jason Beaird is a front-end designer/developer at [MailChimp](http://mailchimp.com/). He spoke about the use of patterns in sustainable web design.*

We tend to start with basic elements on the web, restyling things over and over. Jason believes this isn't necessarily the best way of doing things.

If a project evolves over time, it runs the risk of becoming like a "frankenhouse". For Mailchimp, a redesign required eliminating many small inconsistencies in markup and naming. They went through and derived all of the patterns they could find.

Using patterns allowed Jason to be a master craftsman again, not just a manual laborer.

Style guides and design standards manuals run in the same vein as pattern libraries, but sometimes they stifle creativity rather than encourage it.

Yet another Mailchimp redesign came in 2013 with a focus on responsive design. The pattern library from this redesign is public. It is meant to be used for a specific project or application, to create LEGO-like markup and style, contain elements that are used 3 or more times, and to be adaptable.

One of the main patterns they use is the slat, similar to Drew Barontini's "bucket" in MVCSS.

"A good craftsperson builds their own tools." - Dan Cederholm

*The MailChimp [pattern library](https://ux.mailchimp.com/patterns) is definitely something to take a look at. Jason's approach seems slightly more holistic than the modular CSS talks earlier in the conference, though different projects will likely require different types of thinking about front-end architecture.*

---

### A Frontender Builds a Backend: Learning to Think with your Eyes Closed

**Mason Stewart** - [@masondesu](https://twitter.com/masondesu) - [Website](http://masondesu.com/)

*Mason Stewart is the Lead Instructor at [The Iron Yard](http://theironyard.com/). He spoke about the differences between front-end and back-end feedback that lead front-enders and back-enders to react differently to tasks in their opposite field.*

Why is back-end programming so scary to front-enders? It's intimidating. They say you have to be a "certain kind of person." But this isn't how back-enders usually respond... They just do it.

It is important to remember that there isn't some intellectual gap between front-enders and back-enders. So, we need to dispel the fears. 

* Step one is to understand the similarities. We create for ourselves a bifurcated reality - a divide, a dichotomy - between front- and back-end that doesn't really exist. (We build software in an almost perfect world. Things don't just fall apart due to rust, age, etc. All of programming is similar in this way.)
* Next, understand the differences. The primary difference is the type and degree of feedback. In the front-end, your feedback is primarily visual. JavaScript is a little better about giving informative feedback, but still not that much. Backend errors leave the realm of visual feedback entirely. "We have to learn to be okay with different types, different levels of feedback."
* Learn to play, and try not to worry. You don't have to build cool things. Just build something. Relax.

*Mason's insight into the causes of intimidation for front-enders entering the back-end has the potential to be very helpful. The type and degree of feedback from each realm is indeed very different, and it requires a lot of time to become comfortable with each.*