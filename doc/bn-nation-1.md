> *Name*: DBVN_101
>
> *Status*: draft
>
> *Author*: Eliott Teissonniere (aka DeveloppSoft)
>
> *Created*: 28th of June 2017

# Bitnation DBVN_101 standard

Having a Standard to write Decentralised Borderless Virtual Nation (DBVN) is essential to allow users and DAPPs to interact seamlessly and in a convenient way with your DBVN.

To do so, we established a basic standard all DBVN need to apply, it is described in the following document.


# Basic interfaces

A DBVN is: a code of law, a constitution, a decision pool, a group of citizens and a set of services, as well as some metadata.

All DBVNs implement:
 -  the `onCollapse` function, which is called by the registry when the creator of the nation decides to unregister it. By default, it withdraw all funds to the `backup` address and self destroy.
 -  the `setRegistry` which is used to set the address of the registry in `registry`, it is used to check that the registry is calling a function, through the `onlyRegistry` modifier.
 -  the `onlyRegistry` modifier, it checks that the caller of a given function is the registry, it is used by the `onCollapse` function.

To do so, all new DBVN must be implement the [Nation](../contracts/Nation.sol) interface.


## Code of law

A code of law represents a basic set of laws, owners have the ability to add laws.

The various code of law implementations allows DBVN's creator to select a system of law that has already been established to start from, such as US Common Law, or choose to start from scratch.

A valid DBVN_101 code of law interface must include (interface [here](../contracts/dbvn/CodeOfLaw.sol):
 -  the `nbLaws` variable to reference the number of laws registered.
 -  a list of `Law` structs named `allLaws`, to keep a reference of every laws who have ever been registered, when a law is "disabled", it should stay in this list.
 -  the `Law` struct is composed of the following:
    -  `text` to store law's text.
    -  the `isValid` boolean to tell the users if the law is still valid or not (if it has been repealed).
    -  `createdAt` to register the law's creation date (through `now`).
 -  the string `codeOfLawReference` is used to refer to an ipfs ressource where the articles are described and explained, it is modifiable via `setCodeOfLawReference`, which triggers the event `CodeOfLawReferenceChanged`.
 -  the event `LawChanged` to be triggered when a law is created or repealed.
 -  the functions `addLaw` and `repealLaw` to do the job associated, all laws are identified via their ID (i.e. position in `allLaws`).


## Constitution

The constitution is a verbal set of principles that can be interpreted and expanded upon later. It should be used to direct the development of the DBVN's code.

The consititution can be amended through articles, it defines the basic rules which the DBVN and its laws are based on.

The constitution interface is very similar the code of law one, but please not this are two very different things, a constitution defines which kinds of laws can be made or not, in a way a law is vetted by the constitution.

A constitution interface, as defined in [Constitution.sol](../contracts/dbvn/Constitution.sol) must implement:
 -  the unsigned integer `nbArticles`, associated to the length of the list of `Article` named `articlesOfConstitution`, no elements from this list are ever to be deleted, a special field is associated to each `Article` tolet users repeal them.
 -  the structure `Article` is made of:
    -  the string `summary` to describe the article, such as `We are Privacy and Security`.
    -  the boolean `valid` to check if an article has been repealed or not.
    -  the unsigned integer `createdAt` to log the date of creation.
 -  the string `constitutionReference` is used to refer to an ipfs ressource where the articles are described and explained, it is modifiable via `setConstitutionReference`, which triggers the event `ConstitutionReferenceChanged`.
 -  the event `ArticleChanged`, triggered on article modification.
 -  the functions `addArticle` and `repealArticle`.


## Decision pool

The decision pool is used to take decisions, debate and decide on them.

It allows users to submit proposals, rate or discuss them and finally decide to close or accept them.

This one of the most complex interface of the standard, you can find it [here](../contracts/dbvn/DecisionPool.sol), it implements the following:
 -  the variables `debatingPeriod` and `minimumApproval` are pretty self-explanatory and the represents the diffrent rules to accept a proposal.
 -  a list of `Proposal` named `allProposals`, its length is saved in `nbProposals`.
 -  a `Proposal` is composed of:
    -  `author`: the address of the one who submitted it.
    -  `recipient`: who is the beneficiary of the transaction, it can be the DBVN itself to self-interact with it.
    -  `amount`: the amount of ether to send, it is recommended to compute it via `submitted_amount * 1 ether` for usuability reasons.
    -  `hash`: hash of the transaction (`sha3(p.recipient, p.amount, txBytecode)`), it is used to avoid storing the transaction bytecode on chain (which could cost a lot) but still be sure it will be used.
    -  `description`: quite self-explanatory, it let the author explain the proposal.
    -  `tag`: to let author tag their proposals, thus developers could implement a system where voters have a bigger stake depending of their field of work (as implemented in the original Bitnation DBVN).
    -  `waitingWindow`: to define when a proposal can be executed, this is to ensure proposals have enough time to be debated.
    -  `executed`: to avoid a proposal being executed twice.
    -  `triggered`: set to `true` when the debate time is over, or when the DBVN checked its agreement.
    -  `nbVotes`: how many votes were submitted.
    -  `allVotes`: list of `Vote`, use to calculate if the proposal reached a consensus or not.
    -  `allVoteID`: mapping associating a voter address to a vote ID (position in `allVotes`) to allow vote editing or to check if a citizen already voted.
    -  `approval`: to save the amount of approval reached by the different votes.
 -  a `Vote` is made of:
    -  `voter`: voter's address.
    -  `inSupport`: wether the voter agree or disagree with the proposal.
    -  `comment`: to let citizens explains and justify their vote (can lead to debates).
 -  the event `NewProposal` is triggered when a new proposal is submitted.
 -  the event `ProposalTallied` is used when the proposal have been checked and that the debating period is over (the proposal's field `triggered` must be passed to true).
 -  the event `VoteChanged` is used for new votes or votes being edited.
 -  the event `ChangeOfRules` is triggered when... rules are changed (surprise!).
 -  `changeRules` is used to change the debating period and the minimum approval required.
 -  `newProposal` create a proposal.
 -  `executeProposal` execute a proposal, after checking that a proposal has been accepted.
 -  `checkProposalHash` check that the submitted transaction bytecode match the proposal's hash.
 -  `vote` let citizens vote for or against a proposal.
 -  `getVote` is used to get a specific vote from a specific proposal (used for enumerating purposes).


## Group of citizens

A DBVN must allow various users to apply for citizenship, the decision to accept or refuse it is up to the DBVN.

Users must be allowed to cancel their application or citizenship on their own willing, without any barriers.

Those functions are implemented in a [CitizenRegistry](../contracts/dbvn/CitizenRegistry.sol), all registry must implement:
 -  the public variable `nbUsers`, the users list `allUsers` and the mapping (address to `User` struct) `users`, it is used to list each users and check their citizenship or application state.
 -  each user's address is associated vie `users` to a `User` struct, it keep the following data on the user:
    -  `addr`: its address.
    -  `hasApplication`: true if the user is _waiting_ for its application to be accepted.
    -  `applicationData`: which keep the date (obtained via `now`) when the user submitted its application.
    -  `isCitizen`: true if the user is a citizen.
    -  `citizenSince`: data when the user became a citizen (i.e. when the application has been accepted).
 -  the event `UserChanged` is used when users' data are modified (for instance, it became a citizen, it deleted its application...).
 -  the function `applyForCitizenShip` allows a user to submit its application, it returns the ID of the user (i.e. the position of its address in `allUsers`).
 -  the function `cancelApplication` let a users delete its application by its ID, in that case, the field `hasApplication` of its `User` structure is set to `false`.
 -  the function `acceptApplication` let DBVN's members accept the application of a user and make him a citizen (could be automated).
 -  the function `cancelCitizenship` let a citizen opt-out of the DBVN, its field `isCitizen` is then set to `false`. 


## Services

DBVNs are competing against each others to offer their citizens or all the users better services, since those services are constantly evolving and  improving, they cannot be implemented in the DBVN code itself.

To fix that, the DBVNs must implement a basic "service registry" to publicly list their different services, then it's up to the DBVN to choose who is allowed or not to use those services (only citizens, everyone, only specific users...).

The following part require to implement functions to add or remove Services (even if they are limited to the owner) and to make the services list public.

The [interface](../contracts/dbvn/ServiceRegistry.sol) is made of:
 -  a list of `Service` named `allServices` and associated to `nbServices`.
 -  a `Service` structure has:
    -  a `name`.
    -  a `description`.
    -  its associated contract address in `addr`.
    -  the [ipfs](https://ipfs.io) blob hash of its ABI in `abi` (users can review it).
    -  the boolean `enabled` to say if the service has been shutted down.
    -  `addedOn` is used to log the time when it was registered.
 -  `ServiceChanged` is triggered when a service has been added or edited.
 -  `addService` and `removeService` are used to edit the different services.


## Metadata

DBVN have a special part called "metadata", it allows it to specify a website, a flag or anything else which should be mentionned.

The basic data required by the standard are `name`, `nation_type` (is it a democracy, a dictatorship, an holocracy?), those data should not be modified.

It is recommended to implement a variable `website` to point users the DBVN's website, which could be modified by the owner of the DBVN.

The [interface](../contracts/dbvn/Metadata.sol) implements:
 -  `name`.
 -  `nation_type`, used to mention if the "type" of a DBVN such as dictatorship (totally unrecommended, unless you put me as the dicatator :wink:), democracy, futurarchy or anything else (could be a neologism).
 -  `website` to point users to a place with more informations.
