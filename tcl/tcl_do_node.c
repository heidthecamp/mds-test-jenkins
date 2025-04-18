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
#include <stdlib.h>
#include <string.h>

#include <dcl.h>
#include <mds_stdarg.h>
#include <mdsdescrip.h>
#include <mdsshr.h>
#include <treeshr.h>

/**********************************************************************
 * TCL_DO_NODE.C --
 *
 * TclDoNode:  Execute a node action.
 *
 * History:
 *  27-Apr-1998  TRG  Create.  Ported from original mds code.
 *
 ************************************************************************/

extern int TdiDoTask(mdsdsc_t *, ...);

/***************************************************************
 * TclDoNode:
 ***************************************************************/
EXPORT int TclDoNode(void *ctx, char **error,
                     char **output __attribute__((unused)))
{
  INIT_STATUS, retstatus;
  char *nodnam = NULL;
  int nid;
  DESCRIPTOR_NID(niddsc, &nid);
  DESCRIPTOR_LONG(retstatus_d, &retstatus);
  cli_get_value(ctx, "NODE", &nodnam);
  status = TreeFindNode(nodnam, &nid);
  if (STATUS_OK)
  {
    status = TdiDoTask(&niddsc, &retstatus_d MDS_END_ARG);
    if (STATUS_OK)
      status = retstatus;
  }
  if (STATUS_NOT_OK)
  {
    char *msg = MdsGetMsg(status);
    *error = malloc(strlen(msg) + strlen(nodnam) + 100);
    sprintf(*error,
            "Error: problem doing node %s\n"
            "Error message was: %s\n",
            nodnam, msg);
  }
  free(nodnam);
  return status;
}
