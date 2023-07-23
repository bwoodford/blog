+++
title = "The Great Password Migration"
date = 2020-11-27T12:54:06-06:00
draft = false 
description = "My journey from 1password to pass."
tags = ['Linux']
+++

Recently, I installed Arch Linux as my default Operating System for my desktop. Previously, I had Windows 10 installed, but recieved the Arch experience from years of using it on my laptop. The only scepticism I had was the gaming experience, but after realizing that most of my time was spent programming, I came to the conclusion that this was something I could deal with. I decided to go ahead and make the full transition. 

Fast forward to today, and I'm loving the experience. My last few weekends have been spent configuring every program to my liking; last weekend I was brushing up on some scripting to help with some redundant task management. There's only been one thing missing...an accessible password manager.

For the last year I've been using [1password](https://1password.com/) to manage all of my logins between mobile and desktop. During this switch to linux, I realised that the only way to continue the use of 1password was through the Firefox browser. This was manageable for the first few weeks but the annoyance weened on me.

After a little research, I came across [pass](https://www.passwordstore.org/). Pass is *"the standard unix password manager"*. It abides by the UNIX philosophy: only do one thing and do it well. Pass keeps your passwords secured using a GPG public and private key pair. This allows you to store your passwords in a git repo for exchange with multiple clients (desktop, mobile, work). There's even a blossoming community, built around pass, that has constructed extensions for tombs and otp codes. For my case, [pass-import](https://github.com/roddhjav/pass-import#readme) exists for importing passwords from 53 different password managers (1password included).

First, I started by using my GPG key to generate a new password store **and** initilize a repository for it:
``` bash
# Initialize pass store
% pass init "My GPG Key ID" 
# Create repository for pass store
% pass git init 
```
I also added the remote repository I previously created on my SourceHut account:
``` bash
# Add remote repository
% pass git remote add origin git@git.sr.ht:/~username/pass-repo 
```
Next, I created a fake multiline account to test out the functionality:
``` bash
# Add remote repository
% pass insert -m Website/lobste.rs

Enter contents of Website/lobste.rs and press Ctrl+D when finished:

fakepassword123!
URL: https://www.lobste.rs
Username: username
```
One of my favorite aspects of 1password was keeping the login website URL, username and password in the same place. You can do this with pass, but all the information is just kept in a flat file, with the password at the top for querying purposes:
``` bash
% pass ls
Password Store
└── Website
    └── lobste.rs

% pass show Website/lobste.rs
fakepassword123!
URL: https://www.lobste.rs
Username: username
```
You might also notice that the `pass ls` command shows the `Website` addition as a directory. This is for sorting purposes. You can even use usernames in the directory structure to give more information on the password that you're grabbing out of the store; more information can be found under *Data Organization* on the pass website. 

## Resources
- [Pass Website](https://www.passwordstore.org/)
- [Pass Man Page](https://git.zx2c4.com/password-store/about/)
- [Pass Importer](https://github.com/roddhjav/pass-import#readme)
