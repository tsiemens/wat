#!/usr/bin/env python
import os
import argparse
import ConfigParser

CONFIG_FILE = os.path.expanduser( '~/.wat.conf' )

def repoConfigSectionName( alias ):
    return 'repo %s' % alias

def writeConfig( config ):
    with open( CONFIG_FILE, 'wb' ) as cf:
        config.write( cf )

def getWatFiles( config ):
    files = []
    for repo in config.sections():
        d = config.get( repo, 'dir' )
        files.extend( [ os.path.join( d, f ) for f in os.listdir( d ) \
                        if os.path.isfile( os.path.join( d, f ) ) and f.endswith( '.wat' ) ] )
    return files

class WatTopic( object ):
    def __init__( self, name ):
        self.name = name
        self.summary = ''
        self.entries = []

class WatEntry( object ):
    def __init__( self ):
        self.text = ''
        self.keywords = []

def parseWatFile( filename ):
    with open( filename, 'r' ) as watfile:
        topic = WatTopic( os.path.split( filename )[ 1 ].replace( '.wat', '' ) )
        currentEntry = None
        mode = None
        for line in watfile.readlines():
            if line.strip().startswith( '[SUMMARY]' ):
                mode = 'summary'
            elif line.strip().startswith( '[ENTRY]' ):
                mode = 'entry'
                currentEntry = WatEntry()
                topic.entries.append( currentEntry )
                currentEntry.keywords = [ s for s in line.replace('[ENTRY]', '').replace( '\n', '')\
                                        .split( ' ' ) if len( s ) > 0 ]
            elif mode == 'summary':
                topic.summary += line
            elif mode == 'entry':
                currentEntry.text += line
        return topic

def main():
    argparser = argparse.ArgumentParser( prog='wat',
            description='Searches and provides minimal management interface to personal notes'
                        ' and examples. Items are keyworded, and stored in configurable git repos.' )

    argparser.add_argument( 'topic', type=str, nargs='?',
                            help='The topic to search.' )
    argparser.add_argument( '--add-repo', metavar=( 'ALIAS', 'DIRECTORY' ), type=str, nargs=2,
                            help='Add a locally cloned git repo as a wat repo. The directory '
                                 ' can be a subdirectory in a git repo.')
    argparser.add_argument( '--remove-repo', metavar='ALIAS', type=str,
                            help='Remove a wat repo.' )
    argparser.add_argument( '--list-repos', action='store_true',
                            help='List configured repos.' )
    args = argparser.parse_args()

    config = ConfigParser.RawConfigParser()
    config.read( [ CONFIG_FILE ] )

    if args.add_repo:
        repoSection = repoConfigSectionName( args.add_repo[ 0 ] )
        config.add_section( repoSection )
        config.set( repoSection, 'dir', args.add_repo[ 1 ] )
        writeConfig( config )
    elif args.remove_repo:
        config.remove_section( repoConfigSectionName( args.remove_repo ) )
        writeConfig( config )
    elif args.list_repos:
        for repo in config.sections():
            print '%s: %s' % ( repo.replace( 'repo ', '' ), config.get( repo, 'dir' ) )
    else:
        watFiles = getWatFiles( config )
        topics = []
        for watfile in watFiles:
            topics.append( parseWatFile( watfile ) )
        for topic in topics:
            print topic.summary
            for e in topic.entries:
                print e.keywords
                print e.text

if __name__ == '__main__':
    main()
