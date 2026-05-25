# Profile

I am a creative and versatile software engineer who dives into complex domains to find pragmatic, bespoke solutions across a wide range of technologies. I am also a strong communicator who can easily bridge the gap between technical and non-technical stakeholders. With more than 25 years experience, whether green-fielding new ideas or wrangling legacy code, I help technology teams deliver real value.

## Experience

### Technology Solutions Consultant, Mulberry Labs, October 2019-Present

Provide various capabilities related to professional software development on a consulting basis. Services include, but are not limited to: solutions architecture; product design, development, and support; developer leadership and growth; technical training. Clientele are located variously throughout Europe.

Highlights

- Designed and developed a federated GraphQL gateway in ASP.NET Core (F#) for a Swiss private bank. Said gateway forms the nucleus of client's "data mesh" platform. Additionally, created serveral smaller services (in a mix of F#, Rust, and Python) which feed various sources into the data mesh. Further enhanced said platform by developing several tools for monitoring, reporting, and diagnostic analysis. On-going support of GraphQL gateway includes: maintainence and feature enhancement, helping other developers build services which contribute to the data mesh (including general training on .NET / C# / F# / ASP.NET Core / GraphQL), and training clients (non-technical bank employees) on how to consume data from the federated graph (usually via Python scripts).

- Worked with a Swiss private bank to deliver a comprehenisve approach to securing their in-house data aggregation platform. Plan consisted of an application-level authorization model, and a central identity and authentication management service (IAM). The IAM service, built on ASP.NET Core (F#), married Active Directory with standards-based OIDC/OAuth workflows. Said workflows generated Json Web Tokens (JWTs), which served as claims-based attestations from which participating applications could grant or deny access to features or data. Additionally performed: requirements gathering ahead of development; maintainence where needed; and documentation, training, and onboarding (for new clients and application developers).

- Provided architectural direction, requirements analysis, deep knowledge of specific technologies (especially: F#, C#, ASP.NET Core, and Sql Server), and development support to a rapidly growing team (from 3 people to 7 over a two-month window) building various tools for the digitalization of food manufacturing.

### Senior Software Engineer, eVision Industry Software July 2017-October 2019

Designed, developed, and supported several products (and supporting services) for industrial operational risk management. In support of which, assumed various responsibilities: requirements gathering, back-end coding, front-end coding, quality assurance, level two support, and (when necessary) customer engagement. Also, responsible for mentoring junior developers, serving on advisory boards, participation in funding efforts.

Highlights:

- Architected and developed a web-based risk analysis product, using ASP.NET Core (with a mix of C# and F#) for the back-end. Helped with React/Redux (via TypeScript) for the user interface. Overall programming model combined stream processing, document-based storage, and relational data (all based on Sql Server 2016). Originally worked alone, but as the team grew (adding: three developers, one quality assurance specialist, a development manager, and a product owner) my responsibilities moved away from development and evolved into architecture and technical guidance. Additionally became primary point-of-contact for sales, customer support, and subject matter experts.

- Developed libraries in C# and F# for supporting company’s stable, long-term asset identification scheme. Said libraries ship as re-embedded source code and may be consumed by both .NET Core and .NET Framework code bases. Further, property-based testing was used to provided extension coverage of libraries’ (de)serialization and validation logic.

- Help early development of company’s identity and access management tool. This ASP.NET Core web service, written in C#, provided a centralized, OIDC-compliant federated identity gateway and an OAuth 2.0-compliant secure token server, which helped to provide seamless, integrated authentication and authorization across all the company’s products and services.

### Software Engineer, StatMuse Inc. November 2016-January 2017

Worked as part of a small team (within a ~20-person startup) building novel experiences for sports enthusiasts. Principally helped contribute to a natural language processing (NLP) and natural language generation (NLG) pipeline, which provided “plain English” queries over an extensively curated database of historical sports data for the NBA, NFL, and MLB.

Highlights:

- Introduced monadic and monoidal structured error handling into the hybrid F# and C# code base, while helping to educate team members on using said error handling techniques. Also, provided general guidance on patterns and practices for writing robust cross-language .NET code (while still respecting the idiomatic style of each individual language).

### Associate Director, Jet.com August 2016-November 2016

Participated in the maintenance and evolution of the “pricing engine”, a core e-commerce component which applies complex price adjustments to a large inventory in a quasi-real-time fashion. This required authoring several cloud-based micro services (as part of the company’s bespoke tooling running atop Microsoft’s Azure platform). It additionally necessitated close co-ordination with the product catalog team (for data ingest) and the analytics team (who develop the actual pricing models).

Highlights:

- Designed and executed a plan to migrate away from Redis for replicated storage of the internal data used by several different pricing model calculations. This was part of an overall move to improve the performance of the existing CQRS architecture. It was realized by writing several F# micro services, which worked in concert to consume a mixture of event-sourced catalog data (from EventStore) and internal “commands” (from AzureMQ). Consumed data would be transformed and persisted into DocumentDB, using a DDD-inspired model. Key state changes in the model would be broadcast to interested parties via Kafka.

### Lead Technologist, Quicken Loans August 2014-August 2016

Provided technical leadership to a team of eight engineers as we crafted bespoke software for a business unit that trades mortgages in the financial markets. Primarily responsible for having a detailed understanding of the overall code base and evolving said code base to best meet the needs of the business. This meant: being able to wrangle legacy code, being both strategic and tactical with new code, interacting with external teams, and maintaining clarity on a complex domain model. Also, responsible for: mentoring junior developers, researching new tools and techniques, and guiding the process by which the company converts proprietary solutions into open-source software.

Highlights:

- Led a series of “hands on” training sessions which taught fundamentals of F# and functional programming and showcased key ecosystem tools. This was initially supplemented by reworking certain pieces of legacy code into exemplars that could be studied, but evolved to use production code for demonstration purposes. Additionally, made significant enhancements to the existing infrastructural code to facilitate polyglot solution development.

- Took ownership of a key software library that combines Task-Parallel Library, F# async, and actor-based concurrency to perform dynamic in-memory message dispatching. After refining and open-sourcing the initial code base, I re-worked it to be more stable and robust by leveraging Active Patterns, Code Quotations, and property-based testing (via FsCheck).

- Made a two-pronged approach to address shortcomings is the team’s existing execution of CQRS and event sourcing. First, implemented shared caching via Redis. Second, replaced NEventStore with a simpler, purpose-built event-sourcing model atop Microsoft Sql Server 2012.

### Research Developer, Bayard Rock LLC April 2012-August 2014

Primarily focused on improving the design, execution, and delivery of experiments in the computational entity resolution space. Secondary responsibilities geared toward the productizing of certain findings. Typically, this meant producing and supporting code libraries (i.e. for use by strategic business partners). This combination of responsibilities necessitated close interaction with scientists, business analysis, and IT personnel. It also required navigating between the vagaries of data science and software engineering. Incidental responsibilities included, but were not limited to: ensuring smooth inter-business communications, mentoring developers, and evaluating potential tools to improve primary and secondary responsibilities.

Highlights:

- After a lengthy period of requirements gathering, architected and lead development of a platform for rapid evaluation of machine learning models. The platform consists of two sub-systems: an analysis tool for exploratory scripting, and an execution engine for performing model-driven activities. The web-based analysis tool, which pairs AngularJS on the client-side with ASP.NET Web API on the server-side, lets researchers perform interactive data analysis using F# as a scripting language. The tool features basic data visualization facilities (via FSharp.Charting) and leverages a local NuGet server for controlled dependency management. Data access is realized through F# type providers and secured via standard Windows ACLs. The execution engine, meanwhile, is a distributed work-scheduling system. It leverages ZeroMQ to simplify communications, and uses a combination of the file system and SQL Server for transparency and recovery. Actual work, meanwhile, is realized as “jobs” containing one or more F# scripts, which are executed sequentially and in an isolated process. Thus, providing a convenient path for researchers to transition iterative analysis to long-running experiments.

### Quantitative Developer, Blue Crest Capital LLC March 2010-April 2012

As a front-office developer, working first with equity derivatives and then foreign exchange, the primary focus was “tactical” development: rapid execution of tools addressing immediate risk-management concerns. This required close interaction with portfolio managers, surgically precise enhancements to existing code, and self-directed design and implementation of robust infrastructure components. Secondary responsibilities included: participating in architectural review sessions, ad hoc supplemental desktop support, and evaluating potential new development tools and technologies.

Highlights:

- Designed and executed a deployment management system for a suite of tools leveraged by several different business units. The framework ties the output of a “continuous integration” build server with meta-data collected in a SQL Server database and an end-user-facing management tool. The tool, realized as a WPF (C#) application, allows users to browse, install, back up, or uninstall versions of the cataloged software. Running an instance of the DLR inside the end-user tool carries out actual installation operations. This DLR instance executed bespoke IronPython scripts packaged with each cataloged software entry. Additionally, the tool logs all end-user activity (along-side the catalog meta-data). This utilization data is critical for end-of-year cost settling between business units. Administration of the meta-data catalog, as well as basic utilization reporting, is provided via an Active Directory protected ASP.NET MVC web site, which mixes server-side code (C#) for database manipulation with HTML, CSS, and jQuery for the user interface.

- Worked closely with portfolio manager to create “grey box” trading system, which was realized as a loosely-coupled network of independent Windows Services, coded on the .NET platform, in a mixture of C# and F#, which feed internal and external data to a simple analysis engine, and which also forward trade execution orders generated by the engine. This engine, another Windows Service, leverages a mixture of “inversion of control” and reflective scanning to load trader-specified analysis algorithms at run-time. Additionally, created a simple command-line application for monitoring by a trader. If necessary, the monitoring tool may also be used to intervene in the trade execution process. All communication is handled via custom JSON-encoded messages routed by the Zero MQ distribution framework.

### Senior Software Engineer, Crestron Electronics May 2009-March 2010

Part of a 12-person team delivering the next-generation suite of software tools used to program high-end electronics equipment. As a key technologist on the team, responsibilities included: participating in architectural design sessions, development of core tools and supporting framework components, and providing mentoring to junior developers. Additional responsibilities included evaluating potential new development tools and leading intra-team and inter-departmental training sessions.

Highlights:

- Conceived, designed, and developed a framework for compiling user-supplied interface designs into device-specific packages containing resources and instructions. The core of this framework, coded in F#, wraps a user-supplied data model with a simple set-based query language. Additionally, it provides a pluggable function pipeline, which enables compile-time type-checked data transformations and the injection of custom processing logic. These two pieces are connected via an embedded domain-specific language (DSL), which defines the encoding proper, as either binary or textual output, and serves as useful device-level documentation. Finally, a small script is supplied for additional verification of output generated by the framework.

### Lead Software Engineer, Alere February 2008-May 2009

Served as the technical lead to a team of three developers maintaining and enhancing a web-based health record management system licensed to several health insurance providers. Responsibilities included: translating business requirements into technical specifications, interfacing with vendor and partner business units, design guidance and code review for junior team members, and general application development. Additional responsibilities included: assisting with end-user support, providing development support on other applications, and evaluating potential new development tools and technologies.

Highlights:

- Architected and developed a generic rules engine using a combination of C# and SQL Server. The engine allows complex, run-time evaluated, predicate-driven actions to be expressed in a proper subset of standard C#. Further, the design of the engine allows it to be run as a stand-alone executable, a long-running Windows service, or as a procedure in SQL-hosted CLR. Additionally, coded WinForms and command line utilities to allow administration, testing, and data import from XML documents conforming to the W3C-standardized Rule Interchange Format (RIF). This rules engine has subsequently been utilized as the core of a complex customizable content-delivery system.

### Consultant, October 2005-February 2008

Provided consulting services and custom software solutions. Projects were typically desktop applications or web-based solutions, designed for several different platforms (e.g. Mac OS, Windows), built using a variety of technologies (e.g. Microsoft .NET Framework, Django). Consulting services ranged over the full project life cycle and included: requirements gathering, architecture, development, and training.

Highlights:

- Built a lightweight xcopy-deployable SQL Server administration utility in C#. This tool, which features both graphical and command-line interfaces, was used in several smart-client applications to provide a simplified database installation and maintenance processing, as well as enabling technical support staff to perform live “in the field” trouble-shooting.

- Guided a three-person development team in migrating 20+ web applications, written in a variety of technologies (e.g. ASP/COM+, JSP, PHP, etc.), onto a unified ASP.NET platform which made extensive use of a customized installation of the open-source portal software, .NetNUKE (C#, VB.NET, SQL Server). Along with typical daily tasks (i.e. meeting with users, testing and debugging, etc.), a dearth of existing documentation necessitated reverse-engineering existing products for extended periods of time.

- Worked on the architecture and construction of a sophisticated real estate inspection application. The application featured a desktop data-gathering and report-generation tool (VB.NET, SQL Server), which could be synchronized with a Windows Mobile-based data-gathering tool (VB.NET, Compact Framework), and leveraged SOAP-based web services (C#) and an ASP.NET web site (C#, SQL Server) for product updates and report publishing.

### Developer Consultant, Avanade Inc. February 2004-October 2005

Performed onsite consulting for Fortune 500 clients developing custom solutions based on the Microsoft platform. Individual tasks included: architecture, development, and training. Work was done in teams from three people to twenty-five people.

Highlights:

- Worked on-site with Accenture’s Insurance Services Group to architect and develop a sophisticated reporting framework, which supplemented their existing suite of insurance management applications. This framework consisted of two systems: one which leveraged pluggable custom assemblies to provide business-process-specific manipulation of data, based on a known set of criteria; and another which handled the presentation of report data to any consumer implementing HTTP, SOAP, or .NET Removing. Along with the architecture and documentation, compiled a default business-processing library (VB.NET) and two prototypical service consumers: one leveraging XML and XSLT through SOAP-based web services (C#), and another using Business Objects’ Crystal Reports over HTTP (C#).

### Developer, Econium Inc. June 2001-February 2004

Responsible for the architecture and development of corporate and commercial web-based applications for Fortune 500 clients (Pfizer, Kraft, and others). Services were performed both on-site and from Econium’s offices. Microsoft .NET Framework was typically used as the underlying (server-side) development platform, with the end-user experience driven by a mixture of HTML, JavaScript, and XML. Microsoft SQL Server was typically leveraged as the storage engine. Additional responsibilities included working with designers to ensure production of low-maintenance “code-friendly” layouts and media, and supporting business analysts during requirements gathering by providing onsite rapid prototypes and addressing general technical feasibility concerns.

Highlights:

- Architected and constructed the front-end of a web-based marketing sales reporting tool (C#, SQL Server), which featured the ability to add complex end-user-defined reports to the system dynamically and without modification to the code. Guided approximately 10 developers in the construction of several additional ASP.NET-based reporting components for the system, as well as overall system maintenance.

- Designed and developed the front-end for an award-winning web-based Microsoft PowerPoint presentation repository. Developed using a mix of HTML, JavaScript, and ASP (VBScript), it featured skinable, reusable user-interface components. Additionally, it shipped with several default skins, and the “active” skin could be changed, in real-time, by the end-user.

### Multimedia Instructor, Gibbs College January 2001-June 2002

Developed and taught curriculum for multi-media development based on the tool suites provided by Adobe and, especially, Macromedia.

### Multimedia Producer, PFS Marketwyse October 2000-June 2001

Handled the design and development of rich-media-intensive web sites. Additional responsibilities included providing technical resources and support for sales pitches.

Highlights:

- Worked as part of a five-person development team in the construction of a sea-shored themed online gaming web site. Performed portions of site design (in Adobe Photoshop) and construction (in Macromedia Dreamweaver). Authored several of the games in Macromedia Director. Supervised development of additional games and “look and feel” of graphical and auditory resources. Helped database development team reverse-engineer game-to-server communication from existing PHP code and helped migrate said code to Microsoft ASP.

### Multimedia Producer, Megavideo Productions July 1999-October 2000

Designed and produced web sites and CD-ROMs, which combined audio and video with graphics and interactivity. Additional responsibilities included assisting with audio and video recording and post-production.

Highlights:

- Constructed a complex computer-based training product for medical professionals, which featured an updatable content base and real-time chatting between students and instructors. Designed user interface (in Adobe Photoshop and Adobe Illustrator), based on client-provided guidelines. Authored product as a CD-ROM (in Macromedia Director), and created a companion web site (Microsoft ASP) for serving content updates.

## Education

- Coursera, online — Certificate in Exploratory Data Analysis, 2016
- Coursera, online — Certificate in Getting and Cleaning Data, 2014
- Coursera, online — Certificate in R Programming, 2014
- Coursera, online — Certificate in The Data Scientist’s Toolbox, 2014
- Coursera, online — Certificate in Machine Learning, 2012
- Gibbs College, NJ — Certificate in Visual Communications, 1999
