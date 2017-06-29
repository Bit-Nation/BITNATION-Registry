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

All DBVNs must implement the `onCollapse` function, which is called by the registry when the creator of the nation decides to unregister it. By default, it withdraw all funds to the `backup` address and self destroy.


## Code of law

A code of law represents a basic set of laws, owners have the ability to add laws.

The various code of law implementations allows DBVN's creator to select a system of law that has already been established to start from, such as US Common Law, or choose to start from scratch.


## Constitution

The constitution is a verbal set of principles that can be interpreted and expanded upon later. It should be used to direct the development of the DBVN's code.

The consititution can be amended through articles, it defines the basic rules which the DBVN and its laws are based on.


## Decision pool

The decision pool is used to take decisions, debate and decide on them.

It allows users to submit proposals, rate or discuss them and finally decide to close or accept them.


## Group of citizens

A DBVN must allow various users to apply for citizenship, the decision to accept or refuse it is up to the DBVN.

Users must be allowed to cancel their application or citizenship on their own willing, without any barriers.


## Services

DBVNs are competing against each others to offer their citizens or all the users better services, since those services are constantly evolving and  improving, they cannot be implemented in the DBVN code itself.

To fix that, the DBVNs must implement a basic "service registry" to publicly list their different services, then it's up to the DBVN to choose who is allowed or not to use those services (only citizens, everyone, only specific users...).

Services are editable by the owner of the DBVN, in order to allow users to interact with services seamlessly, a Service is represented by:
 -  a `name`
 -  a `description`
 -  an address, represented by `addr`
 -  an `abi`, which is the JSON file needed to interact with service, the `abi` variable is an URL to download the file, it must be a Panthalassa blob, users will be prompted to review it.

The following part require to implement functions to add or remove Services (even if they are limited to the owner) and to make the services list public.


## Metadata

DBVN have a special part called "metadata", it allows it to specify a website, a flag or anything else which should be mentionned.

The basic data required by the standard are `name`, `nation_type` (is it a democracy, a dictatorship, an holocracy?), those data should not be modified.

It is recommended to implement a variable `website` to point users the DBVN's website, which could be modified by the owner of the DBVN.
