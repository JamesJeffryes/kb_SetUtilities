#BEGIN_HEADER
import os
import sys
import shutil
import hashlib
import subprocess
import requests
import re
import traceback
import uuid
from datetime import datetime
from pprint import pprint, pformat
import numpy as np
import gzip

from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.Alphabet import generic_protein
from biokbase.workspace.client import Workspace as workspaceService
from requests_toolbelt import MultipartEncoder  # added
from biokbase.AbstractHandle.Client import AbstractHandle as HandleService  # added

#END_HEADER


class kb_util_dylan:
    '''
    Module Name:
    kb_util_dylan

    Module Description:
    ** A KBase module: kb_util_dylan
**
** This module contains utilities for manipulating KBase Data Objects
** 
    '''

    ######## WARNING FOR GEVENT USERS #######
    # Since asynchronous IO can lead to methods - even the same method -
    # interrupting each other, you must be *very* careful when using global
    # state. A method could easily clobber the state set by another while
    # the latter method is running.
    #########################################
    #BEGIN_CLASS_HEADER
    workspaceURL = None
    shockURL = None
    handleURL = None

    # target is a list for collecting log messages
    def log(self, target, message):
        # we should do something better here...
        if target is not None:
            target.append(message)
        print(message)
        sys.stdout.flush()

    def get_single_end_read_library(self, ws_data, ws_info, forward):
        pass

    def get_feature_set_seqs(self, ws_data, ws_info):
        pass

    def get_genome_feature_seqs(self, ws_data, ws_info):
        pass

    def get_genome_set_feature_seqs(self, ws_data, ws_info):
        pass

    # config contains contents of config file in a hash or None if it couldn't
    # be found
    def __init__(self, config):
        #BEGIN_CONSTRUCTOR
        self.workspaceURL = config['workspace-url']
        self.shockURL = config['shock-url']
        self.handleURL = config['handle-service-url']
        self.scratch = os.path.abspath(config['scratch'])
        # HACK!! temporary hack for issue where megahit fails on mac because of silent named pipe error
        #self.host_scratch = self.scratch
        self.scratch = os.path.join('/kb','module','local_scratch')
        # end hack
        if not os.path.exists(self.scratch):
            os.makedirs(self.scratch)

        #END_CONSTRUCTOR
        pass


    # Helper script borrowed from the transform service, logger removed
    #
    def upload_file_to_shock(self,
                             console,  # DEBUG
                             shock_service_url = None,
                             filePath = None,
                             ssl_verify = True,
                             token = None):
        """
        Use HTTP multi-part POST to save a file to a SHOCK instance.
        """
        self.log(console,"UPLOADING FILE "+filePath+" TO SHOCK")

        if token is None:
            raise Exception("Authentication token required!")

        #build the header
        header = dict()
        header["Authorization"] = "Oauth {0}".format(token)
        if filePath is None:
            raise Exception("No file given for upload to SHOCK!")

        dataFile = open(os.path.abspath(filePath), 'rb')
        m = MultipartEncoder(fields={'upload': (os.path.split(filePath)[-1], dataFile)})
        header['Content-Type'] = m.content_type

        #logger.info("Sending {0} to {1}".format(filePath,shock_service_url))
        try:
            response = requests.post(shock_service_url + "/node", headers=header, data=m, allow_redirects=True, verify=ssl_verify)
            dataFile.close()
        except:
            dataFile.close()
            raise
        if not response.ok:
            response.raise_for_status()
        result = response.json()
        if result['error']:
            raise Exception(result['error'][0])
        else:
            return result["data"]


    def upload_SingleEndLibrary_to_shock_and_ws (self,
                                                 ctx,
                                                 console,  # DEBUG
                                                 workspace_name,
                                                 obj_name,
                                                 file_path,
                                                 provenance,
                                                 sequencing_tech):

        self.log(console,'UPLOADING FILE '+file_path+' TO '+workspace_name+'/'+obj_name)

        # 1) upload files to shock
        token = ctx['token']
        forward_shock_file = self.upload_file_to_shock(
            console,  # DEBUG
            shock_service_url = self.shockURL,
            filePath = file_path,
            token = token
            )
        #pprint(forward_shock_file)
        self.log(console,'SHOCK UPLOAD DONE')

        # 2) create handle
        self.log(console,'GETTING HANDLE')
        hs = HandleService(url=self.handleURL, token=token)
        forward_handle = hs.persist_handle({
                                        'id' : forward_shock_file['id'], 
                                        'type' : 'shock',
                                        'url' : self.shockURL,
                                        'file_name': forward_shock_file['file']['name'],
                                        'remote_md5': forward_shock_file['file']['checksum']['md5']})

        
        # 3) save to WS
        self.log(console,'SAVING TO WORKSPACE')
        single_end_library = {
            'lib': {
                'file': {
                    'hid':forward_handle,
                    'file_name': forward_shock_file['file']['name'],
                    'id': forward_shock_file['id'],
                    'url': self.shockURL,
                    'type':'shock',
                    'remote_md5':forward_shock_file['file']['checksum']['md5']
                },
                'encoding':'UTF8',
                'type':'fasta',
                'size':forward_shock_file['file']['size']
            },
            'sequencing_tech':sequencing_tech
        }
        self.log(console,'GETTING WORKSPACE SERVICE OBJECT')
        ws = workspaceService(self.workspaceURL, token=ctx['token'])
        self.log(console,'SAVE OPERATION...')
        new_obj_info = ws.save_objects({
                        'workspace':workspace_name,
                        'objects':[
                            {
                                'type':'KBaseFile.SingleEndLibrary',
                                'data':single_end_library,
                                'name':obj_name,
                                'meta':{},
                                'provenance':provenance
                            }]
                        })
        self.log(console,'SAVED TO WORKSPACE')

        return new_obj_info[0]

    #END_CLASS_HEADER

    # config contains contents of config file in a hash or None if it couldn't
    # be found
    def __init__(self, config):
        #BEGIN_CONSTRUCTOR
        self.workspaceURL = config['workspace-url']
        self.shockURL = config['shock-url']
        self.handleURL = config['handle-service-url']
        self.scratch = os.path.abspath(config['scratch'])
        # HACK!! temporary hack for issue where megahit fails on mac because of silent named pipe error
        #self.host_scratch = self.scratch
        self.scratch = os.path.join('/kb','module','local_scratch')
        # end hack
        if not os.path.exists(self.scratch):
            os.makedirs(self.scratch)

        #END_CONSTRUCTOR
        pass


    def KButil_Insert_SingleEndLibrary(self, ctx, params):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN KButil_Insert_SingleEndLibrary
        console = []
        self.log(console,'Running KButil_Insert_SingleEndLibrary with params=')
        self.log(console, "\n"+pformat(params))
        report = 'Running KButil_Insert_SingleEndLibrary with params='
        report += "\n"+pformat(params)


        #### do some basic checks
        #
        if 'workspace_name' not in params:
            raise ValueError('workspace_name parameter is required')
        if 'input_sequence' not in params:
            raise ValueError('input_sequence parameter is required')
        if 'output_name' not in params:
            raise ValueError('output_name parameter is required')


        #### Create the file to upload
        ##
        input_file_name = params['output_name']
        forward_reads_file_path = os.path.join(self.scratch,input_file_name)
        forward_reads_file_handle = open(forward_reads_file_path, 'w', 0)
        self.log(console, 'writing query reads file: '+str(forward_reads_file_path))

        seq_cnt = 0
        fastq_format = False
        input_sequence_buf = params['input_sequence']
        if input_sequence_buf.startswith('@'):
            fastq_format = True
        self.log(console,"INPUT_SEQ: '''\n"+input_sequence_buf+"\n'''")  # DEBUG
        input_sequence_buf = re.sub ('&apos;', "'", input_sequence_buf)
        input_sequence_buf = re.sub ('&#39;',  "'", input_sequence_buf)
        input_sequence_buf = re.sub ('&quot;', '"', input_sequence_buf)
        input_sequence_buf = re.sub ('&#34;',  '"', input_sequence_buf)
        input_sequence_buf = re.sub ('&lt;;',  '<', input_sequence_buf)
        input_sequence_buf = re.sub ('&#60;',  '<', input_sequence_buf)
        input_sequence_buf = re.sub ('&gt;',   '>', input_sequence_buf)
        input_sequence_buf = re.sub ('&#62;',  '>', input_sequence_buf)
        input_sequence_buf = re.sub ('&#36;',  '$', input_sequence_buf)
        input_sequence_buf = re.sub ('&#37;',  '%', input_sequence_buf)
        input_sequence_buf = re.sub ('&#47;',  '/', input_sequence_buf)
        input_sequence_buf = re.sub ('&#63;',  '?', input_sequence_buf)
        input_sequence_buf = re.sub ('&#92;',  "\\", input_sequence_buf)
        input_sequence_buf = re.sub ('&#96;',  '`', input_sequence_buf)
        input_sequence_buf = re.sub ('&#124;', '|', input_sequence_buf)
        input_sequence_buf = re.sub ('&amp;', '&', input_sequence_buf)
        input_sequence_buf = re.sub ('&#38;', '&', input_sequence_buf)
        if not input_sequence_buf.startswith('>') and not input_sequence_buf.startswith('@'):
            forward_reads_file_handle.write('>'+params['output_name']+"\n")
            seq_cnt = 1

        # format checks
        DNA_pattern = re.compile("^[acgtuACGTU ]+$")
        split_input_sequence_buf = input_sequence_buf.split("\n")
        for i,line in enumerate(split_input_sequence_buf):
            if line.startswith('>') or line.startswith('@'):
                seq_cnt += 1
                if not DNA_pattern.match(split_input_sequence_buf[i+1]):
                    if fastq_format:
                        bad_record = "\n".join(split_input_sequence_buf[i],
                                               split_input_sequence_buf[i+1],
                                               split_input_sequence_buf[i+2],
                                               split_input_sequence_buf[i+3])
                    else:
                        bad_record = "\n".join(split_input_sequence_buf[i],
                                               split_input_sequence_buf[i+1])
                    raise ValueError ("BAD record:\n"+bad_record+"\n")
                    sys.exit(0)
            if fastq_format and line.startswith('@'):
                format_ok = True
                seq_len = len(split_input_sequence_buf[i+1])
                if not seq_len > 0:
                    format_ok = False
                if not split_input_sequence_buf[i+1].startswith('+'):
                    format_ok = False
                if not seq_len == len(split_input_sequence_buf[i+3]):
                    format_ok = False
                if not format_ok:
                    raise ValueError ("BAD record:\n"+line+"\n"+split_input_sequence_buf[i+1]+"\n")
                    sys.exit(0)


        # write that sucker, removing spaces
        #
        #forward_reads_file_handle.write(input_sequence_buf)        input_sequence_buf = re.sub ('&quot;', '"', input_sequence_buf)
        for i,line in enumerate(split_input_sequence_buf):
            if line.startswith('>'):
                split_input_sequence_buf[i+1] = re.sub (" ","",split_input_sequence_buf[i+1])
                split_input_sequence_buf[i+1] = re.sub ("\t","",split_input_sequence_buf[i+1])
                forward_reads_file_handle.write(split_input_sequence_buf[i])
                forward_reads_file_handle.write(split_input_sequence_buf[i+1].lower())
            elif line.startswith('@'):
                split_input_sequence_buf[i+1] = re.sub (" ","",split_input_sequence_buf[i+1])
                split_input_sequence_buf[i+1] = re.sub ("\t","",split_input_sequence_buf[i+1])
                split_input_sequence_buf[i+1] = re.sub (" ","",split_input_sequence_buf[i+3])
                split_input_sequence_buf[i+1] = re.sub ("\t","",split_input_sequence_buf[i+3])
                forward_reads_file_handle.write(split_input_sequence_buf[i])
                forward_reads_file_handle.write(split_input_sequence_buf[i+1].lower())
                forward_reads_file_handle.write(split_input_sequence_buf[i+2])
                forward_reads_file_handle.write(split_input_sequence_buf[i+3])

        forward_reads_file_handle.close()


        # load the method provenance from the context object
        #
        self.log(console,"SETTING PROVENANCE")  # DEBUG
        provenance = [{}]
        if 'provenance' in ctx:
            provenance = ctx['provenance']
        # add additional info to provenance here, in this case the input data object reference
        provenance[0]['input_ws_objects'] = []
        provenance[0]['service'] = 'kb_util_dylan'
        provenance[0]['method'] = 'KButil_Insert_SingleEndLibrary'


        # Upload results
        #
        self.log(console,"UPLOADING RESULTS")  # DEBUG

        sequencing_tech = 'N/A'
        self.upload_SingleEndLibrary_to_shock_and_ws (ctx,
                                                      console,  # DEBUG
                                                      params['workspace_name'],
                                                      params['output_name'],
                                                      forward_reads_file_path,
                                                      provenance,
                                                      sequencing_tech
                                                      )

        # build output report object
        #
        self.log(console,"BUILDING REPORT")  # DEBUG
        report += 'sequences in library:  '+str(seq_cnt)

        reportObj = {
            'objects_created':[{'ref':params['workspace_name']+'/'+params['output_name'], 'description':'KButil_Insert_SingleEndLibrary'}],
            'text_message':report
        }

        reportName = 'kbutil_insert_singleendlibrary_report_'+str(hex(uuid.getnode()))
        ws = workspaceService(self.workspaceURL, token=ctx['token'])
        report_obj_info = ws.save_objects({
#                'id':info[6],
                'workspace':params['workspace_name'],
                'objects':[
                    {
                        'type':'KBaseReport.Report',
                        'data':reportObj,
                        'name':reportName,
                        'meta':{},
                        'hidden':1,
                        'provenance':provenance
                    }
                ]
            })[0]

        self.log(console,"BUILDING RETURN OBJECT")
#        returnVal = { 'output_report_name': reportName,
#                      'output_report_ref': str(report_obj_info[6]) + '/' + str(report_obj_info[0]) + '/' + str(report_obj_info[4]),
#                      'output_filtered_ref': params['workspace_name']+'/'+params['output_filtered_name']
#                      }
        returnVal = { 'report_name': reportName,
                      'report_ref': str(report_obj_info[6]) + '/' + str(report_obj_info[0]) + '/' + str(report_obj_info[4]),
                      }
        self.log(console,"KButil_Insert_SingleEndLibrary DONE")

        #END KButil_Insert_SingleEndLibrary

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method KButil_Insert_SingleEndLibrary return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]



    def KButil_FASTQ_to_FASTA(self, ctx, params):
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN KButil_FASTQ_to_FASTA
        console = []
        self.log(console,'Running KButil_FASTQ_to_FASTA with params=')
        self.log(console, "\n"+pformat(params))
        report = 'Running KButil_FASTQ_to_FASTA with params='
        report += "\n"+pformat(params)


        #### do some basic checks
        #
        if 'workspace_name' not in params:
            raise ValueError('workspace_name parameter is required')
        if 'input_name' not in params:
            raise ValueError('input_name parameter is required')
        if 'output_name' not in params:
            raise ValueError('output_name parameter is required')


        # Obtain the input object
        #
        forward_reads_file_compression = None
        sequencing_tech = 'N/A'
        try:
            ws = workspaceService(self.workspaceURL, token=ctx['token'])
            objects = ws.get_objects([{'ref': params['workspace_name']+'/'+params['input_name']}])
            data = objects[0]['data']
            info = objects[0]['info']
            # Object Info Contents
            # absolute ref = info[6] + '/' + info[0] + '/' + info[4]
            # 0 - obj_id objid
            # 1 - obj_name name
            # 2 - type_string type
            # 3 - timestamp save_date
            # 4 - int version
            # 5 - username saved_by
            # 6 - ws_id wsid
            # 7 - ws_name workspace
            # 8 - string chsum
            # 9 - int size 
            # 10 - usermeta meta
            type_name = info[2].split('.')[1].split('-')[0]

            if type_name == 'SingleEndLibrary':
                type_namespace = info[2].split('.')[0]
                if type_namespace == 'KBaseAssembly':
                    file_name = data['handle']['file_name']
                elif type_namespace == 'KBaseFile':
                    file_name = data['lib']['file']['file_name']
                else:
                    raise ValueError('bad data type namespace: '+type_namespace)
                #self.log(console, 'INPUT_FILENAME: '+file_name)  # DEBUG
                if file_name[-3:] == ".gz":
                    forward_reads_file_compression = 'gz'
                if 'sequencing_tech' in data:
                    sequencing_tech = data['sequencing_tech']

        except Exception as e:
            raise ValueError('Unable to fetch input_name object from workspace: ' + str(e))
            #to get the full stack trace: traceback.format_exc()
        
        # pull data from SHOCK
        #
        try:
            if 'lib' in data:
                forward_reads = data['lib']['file']
            elif 'handle' in data:
                forward_reads = data['handle']
            else:
                self.log(console,"bad structure for 'forward_reads'")
                raise ValueError("bad structure for 'forward_reads'")

            ### NOTE: this section is what could be replaced by the transform services
            forward_reads_file_path = os.path.join(self.scratch,forward_reads['file_name'])
            forward_reads_file_handle = open(forward_reads_file_path, 'w', 0)
            self.log(console, 'downloading reads file: '+str(forward_reads_file_path))
            headers = {'Authorization': 'OAuth '+ctx['token']}
            r = requests.get(forward_reads['url']+'/node/'+forward_reads['id']+'?download', stream=True, headers=headers)
            for chunk in r.iter_content(1024):
                forward_reads_file_handle.write(chunk)
            forward_reads_file_handle.close();
            self.log(console, 'done')
            ### END NOTE
        except Exception as e:
            print(traceback.format_exc())
            raise ValueError('Unable to download single-end read library files: ' + str(e))


        #### Create the file to upload
        ##
        output_file_name   = params['output_name']+'.fna'
        output_file_path  = os.path.join(self.scratch,output_file_name)
        input_file_handle  = open(forward_reads_file_path, 'r', -1)
        output_file_handle = open(output_file_path, 'w', -1)
        self.log(console, 'PROCESSING reads file: '+str(forward_reads_file_path))

        seq_cnt = 0
        header = None
        last_header = None
        last_seq_buf = None
        last_line_was_header = False
        for line in input_file_handle:
            if line.startswith('@'):
                seq_cnt += 1
                header = line[1:]
                if last_header != None:
                    output_file_handle.write('>'+last_header)
                    output_file_handle.write(last_seq_buf)
                last_seq_buf = None
                last_header = header
                last_line_was_header = True
            elif last_line_was_header:
                last_seq_buf = line
                last_line_was_header = False
            else:
                continue
        if last_header != None:
            output_file_handle.write('>'+last_header)
            output_file_handle.write(last_seq_buf)

        input_file_handle.close()
        output_file_handle.close()
        

        # load the method provenance from the context object
        #
        self.log(console,"SETTING PROVENANCE")  # DEBUG
        provenance = [{}]
        if 'provenance' in ctx:
            provenance = ctx['provenance']
        # add additional info to provenance here, in this case the input data object reference
        provenance[0]['input_ws_objects'] = []
        provenance[0]['input_ws_objects'].append(params['workspace_name']+'/'+params['input_name'])
        provenance[0]['service'] = 'kb_util_dylan'
        provenance[0]['method'] = 'KButil_FASTQ_to_FASTA'


        # Upload results
        #
        self.log(console,"UPLOADING RESULTS")  # DEBUG

        self.upload_SingleEndLibrary_to_shock_and_ws (ctx,
                                                      console,  # DEBUG
                                                      params['workspace_name'],
                                                      params['output_name'],
                                                      output_file_path,
                                                      provenance,
                                                      sequencing_tech
                                                      )

        # build output report object
        #
        self.log(console,"BUILDING REPORT")  # DEBUG
        report += 'sequences in library:  '+str(seq_cnt)

        reportObj = {
            'objects_created':[{'ref':params['workspace_name']+'/'+params['output_name'], 'description':'KButil_FASTQ_to_FASTA'}],
            'text_message':report
        }

        reportName = 'kbutil_fastq_to_fasta_report_'+str(hex(uuid.getnode()))
        ws = workspaceService(self.workspaceURL, token=ctx['token'])
        report_obj_info = ws.save_objects({
#                'id':info[6],
                'workspace':params['workspace_name'],
                'objects':[
                    {
                        'type':'KBaseReport.Report',
                        'data':reportObj,
                        'name':reportName,
                        'meta':{},
                        'hidden':1,
                        'provenance':provenance
                    }
                ]
            })[0]

        self.log(console,"BUILDING RETURN OBJECT")
#        returnVal = { 'output_report_name': reportName,
#                      'output_report_ref': str(report_obj_info[6]) + '/' + str(report_obj_info[0]) + '/' + str(report_obj_info[4]),
#                      'output_filtered_ref': params['workspace_name']+'/'+params['output_filtered_name']
#                      }
        returnVal = { 'report_name': reportName,
                      'report_ref': str(report_obj_info[6]) + '/' + str(report_obj_info[0]) + '/' + str(report_obj_info[4]),
                      }
        self.log(console,"KButil_FASTQ_to_FASTA DONE")

        #END KButil_FASTQ_to_FASTA

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method KButil_FASTQ_to_FASTA return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

