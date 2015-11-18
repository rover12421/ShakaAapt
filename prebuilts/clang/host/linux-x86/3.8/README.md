Android Clang/LLVM
==================

Platform Projects
-----------------

#### external/llvm
**Branch**: *aosp/dev*

* This branch tracks LLVM upstream directly and contains our Android-specific
  patches that do not exist in upstream.

**Branch**: *aosp/master*

* This branch receives updates from the *aosp/dev* branch as a squashed single
  commit.
  Any patches submitted here need to be replayed in *aosp/dev* as well for
  consistency with future rebases.

#### external/clang
**Branch**: *aosp/dev*

* This branch tracks Clang upstream directly and contains our Android-specific
  patches that do not exist in upstream.

**Branch**: *aosp/master*

* This branch receives updates from the *aosp/dev* branch as a squashed single
  commit.
  Any patches submitted here need to be replayed in *aosp/dev* as well for
  consistency with future rebases.

#### external/compiler-rt
**Branch**: *aosp/dev*

* This branch tracks compiler-rt upstream directly and contains our
  Android-specific patches that do not exist in upstream.

**Branch**: *aosp/master*

* This branch receives updates from the *aosp/dev* branch as a squashed single
  commit.
  Any patches submitted here need to be replayed in *aosp/dev* as well for
  consistency with future rebases.


**Note**: Similar branching strategies can be used for **external/libcxx** and
**external/libcxxabi**, but these projects are less divergent and may not need
special LLVM rebase behavior.


Development Flow
----------------

Rebases take place in the **external/** *aosp/dev* branches by merging
upstream CLs directly.
Conflicts are resolved manually and then a patch is produced to adapt
Android.mk files (as well as to add/delete any updated source files).
Prebuilts are then generated using these projects and placed into the proper
**prebuilts/clang/host** subprojects.

For example, these projects for LLVM 3.8 would be:

    prebuilts/clang/host/linux-x86/3.8
    prebuilts/clang/host/darwin-x86/3.8
    prebuilts/clang/host/windows-x86/3.8

In order to prepare for the actual rebase (including updating dependent
projects), we will copy each **external/** *aosp/dev* project to its
corresponding **external/** *aosp/master* project as a squashed single CL.
This makes rollbacks simpler, and it also reduces churn on the Android build
servers.
This also has the side effect of not spamming non-Android @google.com
committers to upstream LLVM projects, since their commits will be batched up
into a single copy commit on each tracked **external/** project.

Prebuilts for llvm-rs-cc and bcc\_compat also need to be generated for
prebuilts/sdk.
This is done by running **frameworks/rs/update\_rs\_prebuilts.sh** on both Mac
and Linux.
After this completes, the **prebuilts/sdk** project will have a prepared
branch/CL that can be uploaded for review/commit.


Fixing Bugs
-----------

If we find a host-side bug that needs to be fixed, it may trigger an update of
the host prebuilts (i.e. rebase).
Device-side fixes can be pushed directly to **external/** *aosp/master* and then
copied to **external/** *aosp/dev* to speed up the process (assuming that it
doesn’t affect the host builds).


Looking at Upstream
-------------------

Here are the remotes to add in your **external/** projects. You can synchronize
them with `git fetch upstream`.


    Clang: git remote add upstream http://llvm.org/git/clang.git
    LLVM:  git remote add upstream http://llvm.org/git/llvm.git
    compiler-rt: git remote add upstream http://llvm.org/git/compiler-rt.git


LLVM 3.8 era rebase process
---------------------------

Loop over llvm, clang, compiler-rt (in this order):

1. We are working from a separate untracked/merged branch called *aosp/dev*,
   so we can’t really use repo start.

        git branch -D working_dev
        git checkout -b working_dev aosp/dev

2. **OPTIONAL FIXUPS**.
   These aren't really necessary if you remember to always keep *aosp/dev* and
   *aosp/master* synchronized otherwise, but very often someone will forget to
   merge back a change.

  1. Grab the squashed commit that went into *aosp/master* and mark it
     committed to *aosp/dev* too.

     **Note**: If there were changes to *aosp/master* before the squashed
     commit, grab those changes (using step 2), before applying this step,
     and finally repeat step 2 for changes after the squashed commit.

          git branch -D clean_master
          git checkout -b clean_master <SHA_FOR_SQUASH>
          git checkout working_dev
          git merge -s ours clean_master
          git push aosp refs/heads/working_dev:refs/heads/dev
          git branch -D clean_master

  2. Grab all outstanding changes that went into *aosp/master* and put them
     into *aosp/dev* too.

          git branch -D clean_master
          git checkout -b clean_master aosp/master
          git checkout working_dev
          git merge clean_master
          git push aosp refs/heads/working_dev:refs/heads/dev
          git branch -D clean_master

3. Merge the upstream branch.
   Use `git log upstream/master` to browse upstream commits and find a SHA.

        git merge <upstream_sha>

4. Fix conflicts.

5. Update build rules and commit that patch on top.

6. Test everything before pushing.

7. Submit your work to *aosp/dev*.

        git push aosp refs/heads/working_dev:refs/heads/dev

8. Squash your work for *aosp/master*.

        repo start update_38 .
        git merge --squash working_dev
        git commit -a
        repo upload .

9. Test everything before submitting the patch from the previous step.

10. Grab the squashed commit and replay it in *aosp/dev*.

        repo sync .
        git remote update
        git branch -D clean_master
        git checkout -b clean_master aosp/master
        git checkout working_dev

    Use `-s ours` to ensure that we skip the squashed set of changes.
    If/when we forget this, we have to do it later.

        git merge -s ours clean_master
        git push aosp refs/heads/working_dev:refs/heads/dev
        git branch -D clean_master

11. Clean up after our working branch.

        git checkout --detach
        git branch -D working_dev

This works better because we can keep full history in *aosp/dev*, while
maintaining easy reverts/commits through *aosp/master*.

Generating new prebuilts
------------------------

1. Build all of llvm/clang/compiler-rt.

        cd $ANDROID_BUILD_TOP/
        mmma external/llvm external/clang external/compiler-rt -j48

        cd $ANDROID_BUILD_TOP/prebuilts/clang/host/linux-x86/3.8
        ./build_toolchain.sh
        ./build_profile_rt.sh

2. Copy over our new prebuilts.
Note that these were built with the previous clang.

        ./update.sh

3. Now we need to actually rebuild everything with the new clang.
This includes clang itself!

        rm -rf out/
        ./build_toolchain.sh
        ./build_profile_rt.sh

4. Now we need to copy over our actual self-hosted prebuilts.

        ./update.sh

5. Rebuild/test everything one more time to ensure correctness.
There may be necessary fixups here, to handle .ll reading or other projects
where new warnings/errors are firing.

        m -j48 checkbuild

6. Upload the changes produced in **prebuilts/clang/host**.
This may entail more than a simple `git commit -a`, so look at `git status`
before finally uploading/committing.

        repo start updated_toolchain .
        git commit -a
        repo upload --cbr .

7. Update RenderScript prebuilts.

        cd $ANDROID_BUILD_TOP/frameworks/rs
        ./update_rs_prebuilts.sh

8. The prebuilts get copied to **prebuilts/sdk**, so we must upload the
relevant bits from there.

        cd $ANDROID_BUILD_TOP/prebuilts/sdk
        git commit -a
        repo upload .

9. Submit CLs.


Steps/Checklist for testing:
----------------------------

1. Do a Clang-only build and ensure it is not broken:

        USE_CLANG_PLATFORM_BUILD=true m -j48

2. Go to **external/llvm** and run `./android_test.sh` (no known failures
as of 2015-10-08).
3. Ensure successful build for all architectures: 32- and 64- bit ARM, x86 and
Mips.
4. Run 32- and 64- bit RenderScript CTS at least for ARM and AArch64.
5. Test RenderScript apps: RsTest, ImageProcessing, and finally
RSTest\_Compatlib in compatibility mode.
6. Test old APKs with rebased tools: grab the above apps from a different tree
(i.e. without the rebase), push them to a device with the rebased tools, and
test.
This ensures that the rebased BitcodeReader can read the output of old
BitcodeWriters.
7. Test new APKs on an old device: test freshly built APKs for
RSTest\_V{11,14,16}, and ImageProcessing\_2 on an old device (say Manta) and
ensure they pass.
This ensures that the rebase did not break the 2.9 and 3.2 BitcodeWriters.
8. Run ART host tests.
This was broken by a rebase once, and worth testing after every rebase.

        croot && cd art && mma -j40 test-art-host

9. Run ART device tests.

        croot && cd art && mma -j4 test-art-device


Checklist for CLs
-----------------

The following projects will almost always have CLs as a part of the rebase.
Depending on the changes in LLVM, there might be updates to other projects as
well.

* External projects

  * **external/clang**
  * **external/compiler-rt**
  * **external/llvm**
  * **frameworks/compile/mclinker**

* RenderScript projects

  * **frameworks/compile/libbcc**
  * **frameworks/compile/slang**
  * **frameworks/rs**

* Prebuilts

  * **prebuilts/clang/host/darwin-x86/**
  * **prebuilts/clang/host/linux-x86/**
  * **prebuilts/clang/host/windows-x86/**
  * **prebuilts/sdk**

* CTS tests

  * **cts/tests/tests/renderscript**
  * **cts/tests/tests/renderscriptlegacy**
  * **cts/tests/tests/rscpp**

