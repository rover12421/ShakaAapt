import time

import libcxx.test.executor

from libcxx.android import adb
from lit.util import executeCommand  # pylint: disable=import-error


class AdbExecutor(libcxx.test.executor.RemoteExecutor):
    def __init__(self, serial=None):
        # TODO(danalbert): Should factor out the shared pieces of SSHExecutor
        # so we don't have this ugly parent constructor...
        super(AdbExecutor, self).__init__()
        self.serial = serial
        self.local_run = executeCommand

    def _remote_temp(self, is_dir):
        dir_arg = '-d' if is_dir else ''
        cmd = 'mktemp -q {} /data/local/tmp/libcxx.XXXXXXXXXX'.format(dir_arg)
        temp_path, err, exitCode = self._execute_command_remote([cmd])
        temp_path = temp_path.strip()
        if exitCode != 0:
            raise RuntimeError(err)
        return temp_path

    def _copy_in_file(self, src, dst):  # pylint: disable=no-self-use
        adb.push(src, dst)

    def _execute_command_remote(self, cmd, remote_work_dir='.', env=None):
        adb_cmd = ['adb', 'shell']
        if self.serial:
            adb_cmd.extend(['-s', self.serial])
        if env:
            env_cmd = ['env'] + ['%s=%s' % (k, v) for k, v in env.items()]
        else:
            env_cmd = []
        remote_cmd = ' '.join(env_cmd + cmd + ['; echo $?'])
        if remote_work_dir != '.':
            remote_cmd = 'cd {} && {}'.format(remote_work_dir, remote_cmd)
        adb_cmd.append(remote_cmd)

        # Tests will commonly fail with ETXTBSY. Possibly related to this bug:
        # https://code.google.com/p/android/issues/detail?id=65857. Work around
        # it by just waiting a second and then retrying.
        for _ in range(10):
            out, err, exit_code = self.local_run(adb_cmd)
            if 'Text file busy' in out:
                time.sleep(1)
            else:
                # The inner strip is to make sure we don't have garbage at
                # either end of the list. The outer strip is for compatibility
                # with old adbd's that would send \r\n.
                out = [s.strip() for s in out.strip().split('\n')]
                status_line = out[-1:][0]
                out = '\n'.join(out[:-1])
                exit_code = int(status_line)
                break
        return out, err, exit_code
