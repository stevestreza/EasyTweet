Overview
========

EasyTweet is a simple set of Objective-C classes for making API calls to the Twitter API with one (included) dependency. It manages OAuth for you, including login, without depending on external OAuth libraries. At its core are three classes:

- ETWTwitterApp, which manages credentials about your app and user accounts
- ETWAccount, which manages credentials for a user of a given ETWTwitterApp (NSCoding-enabled, so you can persist these)
- ETWRequest, which manages OAuth, signs API requests, and returns structured responses

How To Use
==========

1) Create an ETWTwitterApp using OAuth credentials from dev.twitter.com.
2) Login using the ETWTwitterApp login APIs to get an ETWAccount
3) Make ETWRequests combining the ETWTwitterApp and ETWAccount

ARC
===

EasyTweet uses ARC for memory management.

Development Status
==================

Development is not fully complete, so use at your own risk.

Wish List
=========

- photo uploading
- OAuth unit tests from Twitter docs
- Objective-C APIs for individual Twitter endpoints
- import system accounts to ETWAccount objects

Attribution
===========

EasyTweet uses a base64 encoder/decoder from https://github.com/nicklockwood/Base64.

License
=======

Copyright (c) 2012 Steve Streza

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.