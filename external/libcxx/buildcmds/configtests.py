#!/usr/bin/env python
from __future__ import print_function
import getopt
import sys


def main():
    try:
        opts, _ = getopt.getopt(sys.argv[1:], '', [
            'bitness=', 'compiler=', 'host'])
    except getopt.GetoptError as err:
        sys.exit(err)

    bitness = None
    compiler = 'clang'
    host = False
    for opt, val in opts:
        if opt == '--bitness':
            bitness = int(val)
            if bitness not in (32, 64):
                sys.exit('Invalid bitness: {}'.format(bitness))
        elif opt == '--compiler':
            if val not in ('clang', 'gcc'):
                sys.exit('Unknown compiler: {}'.format(val))
            compiler = val
        elif opt == '--host':
            host = True
        else:
            raise NotImplementedError('unhandled option: {}'.format(opt))

    with open('external/libcxx/buildcmds/testconfig.mk', 'w') as test_config:
        if compiler == 'clang':
            print('LOCAL_CLANG := true', file=test_config)
        elif compiler == 'gcc':
            print('LOCAL_CLANG := false', file=test_config)

        if bitness == 32:
            print('LOCAL_MULTILIB := 32', file=test_config)
        elif bitness == 64:
            print('LOCAL_MULTILIB := 64', file=test_config)

        if compiler == 'clang':
            print('LOCAL_CXX := $(LOCAL_PATH)/buildcmdscc $(CLANG_CXX)',
                  file=test_config)
        else:
            if host:
                prefix = 'HOST_'
            else:
                prefix = 'TARGET_'
            print('LOCAL_CXX := $(LOCAL_PATH)/buildcmdscc '
                  '$($(LOCAL_2ND_ARCH_VAR_PREFIX){}CXX)'.format(prefix),
                  file=test_config)

        if host:
            print('include $(BUILD_HOST_EXECUTABLE)', file=test_config)
        else:
            print('include $(BUILD_EXECUTABLE)', file=test_config)


if __name__ == '__main__':
    main()
