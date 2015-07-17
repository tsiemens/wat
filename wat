#!/usr/bin/env python
import os
import argparse
import ConfigParser

CONFIG_FILE = os.path.expanduser( '~/.wat.conf' )

def main():
    argparser = argparse.ArgumentParser( prog='wat',
            description='Searches and provides minimal management interface to personal notes'
                        ' and examples. Items are keyworded, and stored in configurable git repos.' )

    argparser.add_argument( 'topic', type=str, nargs='?',
                            help='The topic to search.' )
    argparser.add_argument( '--add-repo', metavar=( 'ALIAS', 'DIRECTORY' ), type=str, nargs=2,
                            help='Add a locally cloned git repo as a wat repo.' )
    argparser.add_argument( '--remove-repo', metavar='ALIAS', type=str,
                            help='Remove a wat repo.' )
    args = argparser.parse_args()

    configParser = ConfigParser.RawConfigParser()
    repobs = 'repo bs'
    configParser.add_section( repobs )
    configParser.set( repobs, 'dir', os.path.expanduser( '~/src/wat' ) )
    configParser.read( [ CONFIG_FILE ] )
    #with open( CONFIG_FILE, 'wb' ) as cf:
    #    configParser.write( cf )

if __name__ == '__main__':
    main()
