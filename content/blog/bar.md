---
title: "Bar"
date: 2020-07-11T16:02:23-05:00
draft: true
---

One of the major problems of a test automation framework is the change of data that makes the tests flaky. Because if someone/or some process changes the data that was used by the test, the test would fail. One way to solve this issue is to create test data as part of the test itself. This makes test more robust because the data is now part of the test and it can’t change. In a previous post we discussed about the strategies to generate test data using POJOs and Lombok’s builder. This is a continuation of that post, but it’s more focused on the use of random data instead of using static values. With random data, we are communicating that the particular piece of data is not relevant to the specific test. We want to generate data to reduce the amount of boilerplate, and make tests clear in terms of what data is required to exercise the test without generating a bunch of noise that is not relevant to the test. In a sense, we aspire to create robust tests by using random values.
