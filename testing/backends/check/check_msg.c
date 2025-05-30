/*
Copyright (c) 2017, Massachusetts Institute of Technology All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this
list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/*
 * Check: a unit test framework for C
 * Copyright (C) 2001 2002, Arien Malec
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#include "lib/libcompat.h"

#include <sys/types.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>

#include "check_error.h"
#include "check.h"

#include "check_list.h"
#include "check_impl.h"
#include "check_msg.h"
#include "check_pack.h"
#include "check_str.h"

/* 'Pipe' is implemented as a temporary file to overcome message
 * volume limitations outlined in bug #482012. This scheme works well
 * with the existing usage wherein the parent does not begin reading
 * until the child has done writing and exited.
 *
 * Pipe life cycle:
 * - The parent creates a tmpfile().
 * - The fork() call has the effect of duplicating the file descriptor
 *   and copying (on write) the FILE* data structures.
 * - The child writes to the file, and its dup'ed file descriptor and
 *   data structures are cleaned up on child process exit.
 * - Before reading, the parent rewind()'s the file to reset both
 *   FILE* and underlying file descriptor location data.
 * - When finished, the parent fclose()'s the FILE*, deleting the
 *   temporary file, per tmpfile()'s semantics.
 *
 * This scheme may break down if the usage changes to asynchronous
 * reading and writing.
 */

static FILE *send_file1;
static char *send_file1_name;
static FILE *send_file2;
static char *send_file2_name;

static FILE *get_pipe(void);
static void setup_pipe(void);
static void teardown_pipe(void);
static TestResult *construct_test_result(RcvMsg *rmsg, int waserror);
static void tr_set_loc_by_ctx(TestResult *tr, enum ck_result_ctx ctx,
                              RcvMsg *rmsg);
static FILE *get_pipe(void)
{
  if (send_file2 != 0)
  {
    return send_file2;
  }

  if (send_file1 != 0)
  {
    return send_file1;
  }

  eprintf("No messaging setup", __FILE__, __LINE__);

  return NULL;
}

void send_failure_info(const char *msg, int rtype)
{
  FailMsg fmsg;

  fmsg.msg = strdup(msg);
  fmsg.rtype = rtype;
  ppack(get_pipe(), CK_MSG_FAIL, (CheckMsg *)&fmsg);
  free(fmsg.msg);
}

void send_duration_info(int duration)
{
  DurationMsg dmsg;

  dmsg.duration = duration;
  ppack(get_pipe(), CK_MSG_DURATION, (CheckMsg *)&dmsg);
}

void send_loc_info(const char *file, int line)
{
  LocMsg lmsg;

  lmsg.file = strdup(file);
  lmsg.line = line;
  ppack(get_pipe(), CK_MSG_LOC, (CheckMsg *)&lmsg);
  free(lmsg.file);
}

void send_ctx_info(enum ck_result_ctx ctx)
{
  CtxMsg cmsg;

  cmsg.ctx = ctx;
  ppack(get_pipe(), CK_MSG_CTX, (CheckMsg *)&cmsg);
}

TestResult *receive_test_result(int waserror)
{
  FILE *fp;
  RcvMsg *rmsg;
  TestResult *result;

  fp = get_pipe();
  if (fp == NULL)
  {
    eprintf("Error in call to get_pipe", __FILE__, __LINE__ - 2);
  }

  rewind(fp);
  rmsg = punpack(fp);

  if (rmsg == NULL)
  {
    eprintf("Error in call to punpack", __FILE__, __LINE__ - 4);
  }

  teardown_pipe();
  setup_pipe();

  result = construct_test_result(rmsg, waserror);
  rcvmsg_free(rmsg);
  return result;
}

static void tr_set_loc_by_ctx(TestResult *tr, enum ck_result_ctx ctx,
                              RcvMsg *rmsg)
{
  if (ctx == CK_CTX_TEST)
  {
    tr->file = rmsg->test_file;
    tr->line = rmsg->test_line;
    rmsg->test_file = NULL;
    rmsg->test_line = -1;
  }
  else
  {
    tr->file = rmsg->fixture_file;
    tr->line = rmsg->fixture_line;
    rmsg->fixture_file = NULL;
    rmsg->fixture_line = -1;
  }
}

static TestResult *construct_test_result(RcvMsg *rmsg, int waserror)
{
  TestResult *tr;

  if (rmsg == NULL)
    return NULL;

  tr = tr_create();

  if (rmsg->msg != NULL || waserror)
  {
    if (rmsg->failctx != CK_CTX_INVALID)
    {
      tr->ctx = rmsg->failctx;
      tr->rtype = rmsg->rtype;
    }
    else
    {
      tr->ctx = rmsg->lastctx;
    }

    tr->msg = rmsg->msg;
    rmsg->msg = NULL;
    tr_set_loc_by_ctx(tr, tr->ctx, rmsg);
  }
  else if (rmsg->lastctx == CK_CTX_SETUP)
  {
    tr->ctx = CK_CTX_SETUP;
    tr->msg = NULL;
    tr->rtype = CK_PASS;
    tr_set_loc_by_ctx(tr, CK_CTX_SETUP, rmsg);
  }
  else
  {
    tr->ctx = CK_CTX_TEST;
    tr->msg = NULL;
    tr->rtype = CK_PASS;
    tr->duration = rmsg->duration;
    tr_set_loc_by_ctx(tr, CK_CTX_TEST, rmsg);
  }

  return tr;
}

void setup_messaging(void) { setup_pipe(); }

void teardown_messaging(void) { teardown_pipe(); }

/**
 * Open a temporary file.
 *
 * If the file could be unlinked upon creation, the name
 * of the file is not returned via 'name'. However, if the
 * file could not be unlinked, the name is returned,
 * expecting the caller to both delete the file and
 * free the 'name' field after the file is closed.
 */
FILE *open_tmp_file(char **name)
{
  FILE *file = NULL;

  *name = NULL;

#ifndef HAVE_MKSTEMP
  /* Windows does not like tmpfile(). This is likely because tmpfile()
   * call unlink() on the file before returning it, to make sure the
   * file is deleted when it is closed. The unlink() call also fails
   * on Windows if the file is still open. */
  /* also note that mkstemp is apparently a C90 replacement for tmpfile */
  /* perhaps all we need to do on Windows is set TMPDIR to whatever is
     stored in TEMP for tmpfile to work */
  /* and finally, the "b" from "w+b" is ignored on OS X, not sure about WIN32 */

  file = tmpfile();
  if (file == NULL)
  {
    char *tmp = getenv("TEMP");
    char *tmp_file = tempnam(tmp, "check_");

    /*
     * Note, tempnam is not enough to get a unique name. Between
     * getting the name and opening the file, something else also
     * calling tempnam() could get the same name. It has been observed
     * on MinGW-w64 builds on Wine that this exact thing happens
     * if multiple instances of a unit tests are running concurrently.
     * To prevent two concurrent unit tests from getting the same file,
     * we append the pid to the file. The pid should be unique on the
     * system.
     */
    char *uniq_tmp_file = ck_strdup_printf("%s.%d", tmp_file, getpid());

    file = fopen(uniq_tmp_file, "w+b");
    *name = uniq_tmp_file;
    free(tmp_file);
  }
#else
  int fd = -1;
  const char *tmp_dir = getenv("TEMP");
  if (!tmp_dir)
  {
    tmp_dir = ".";
  }

  *name = ck_strdup_printf("%s/check_XXXXXX", tmp_dir);

  if (-1 < (fd = mkstemp(*name)))
  {
    file = fdopen(fd, "w+b");
    if (0 == unlink(*name) || NULL == file)
    {
      free(*name);
      *name = NULL;
    }
  }
#endif
  return file;
}

static void setup_pipe(void)
{
  if (send_file1 == NULL)
  {
    send_file1 = open_tmp_file(&send_file1_name);
    return;
  }
  if (send_file2 == NULL)
  {
    send_file2 = open_tmp_file(&send_file2_name);
    return;
  }
  eprintf("Only one nesting of suite runs supported", __FILE__, __LINE__);
}

static void teardown_pipe(void)
{
  if (send_file2 != 0)
  {
    fclose(send_file2);
    send_file2 = 0;
    if (send_file2_name != NULL)
    {
      unlink(send_file2_name);
      free(send_file2_name);
      send_file2_name = NULL;
    }
  }
  else if (send_file1 != 0)
  {
    fclose(send_file1);
    send_file1 = 0;
    if (send_file1_name != NULL)
    {
      unlink(send_file1_name);
      free(send_file1_name);
      send_file1_name = NULL;
    }
  }
  else
  {
    eprintf("No messaging setup", __FILE__, __LINE__);
  }
}
