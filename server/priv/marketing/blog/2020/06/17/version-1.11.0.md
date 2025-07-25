---
title: Easily setup signing for your project with Tuist 1.11.0 Volare
category: "product"
tags:
  [
    Tuist,
    release,
    swift,
    project generation,
    xcode,
    apple,
    '1.11.0',
    'fastlane',
    'automation',
  ]
excerpt: The new Tuist release 1.11.0 Volare introduces a signing feature to help you with maintaining and integrating your signing artifacts.
author: fortmarek
---

Hi! 👋

I am really excited to write this blog post as we have a great new feature for you to use -
and this feature is signing 🔑

So, let's dive right into it 🏊‍♂️

## Signing

Signing is one of the most complicated domains that iOS developers
have to deal with in Xcode. And although Apple has introduced automatic signing feature,
most teams have decided not to use it as it creates a messy environment for their team.

With the new feature, you'll be able to put your provisioning profiles and certificates
into `Tuist/Signing` directory and ... just run `tuist generate`. That's it!
No figuring out how to set up the Xcode build settings as that is done for you.
And as a plus your signing artifacts will be automatically encrypted with
your key at `master.key`, so you can safely push it to your remote
repository, so other team members can run the apps on a device, too ✨
You can find more info in the [documentation](https://docs.old.tuist.io/commands/signing/)

You can also check out an introduction video where we
show you the feature in action:

https://youtu.be/WGKp1EHcpME

Feel free to try it out and let us know your feedback! 🙂

Note that we are also working hard on automating the process
of generating provisioning profiles and certificates for you. Stay tuned 👀

## Build

We are still continuing to work on `build` feature, thanks to [@pepicrft](https://github.com/pepicrft)
it is now possible to run `tuist build --configuration Configuration` to specify the configuration you want to build.
There is more to come, so keep yourself updated 📝

## Other improvements

- Thanks to [@davidbrunow](https://github.com/davidbrunow) there is now support for Watch architecture ⌚

### Bug fixes

- Fix `tuist build` building a wrong workspace [#1427](https://github.com/tuist/tuist/pull/1427) by [@fortmarek](https://github.com/fortmarek)
- `tuist edit` always creates a project in a new temp dir [#1424](https://github.com/tuist/tuist/pull/1424) by [@fortmarek](https://github.com/fortmarek)
- Fix `tuist init` and `tuist scaffold` with new ArgumentParser version [#1425](https://github.com/tuist/tuist/pull/1425) by [@fortmarek](https://github.com/fortmarek)
- `--clean` argument ot the build command [#1421](https://github.com/tuist/tuist/pull/1421) by [@pepicrft](https://github.com/pepicrft)

## Closing words

To try out the new `signing` feature run `tuist update`.
We are also extremely happy to see more teams adopting tuist
as they are trying to achieve scalable projects
that are still joy to work on!

Let us know your thoughts, ideas and experiences on [our community forum](https://community.tuist.io) and [Slack group](https://slack.tuist.io),
we are always keen to make other voices heard in the community! 🙂

Thanks for reading and stay safe.
