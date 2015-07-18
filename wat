#!/usr/bin/env python
# Copyright (c) 2015 tsiemens
import os
import re
import argparse
import ConfigParser

CONFIG_FILE = os.path.expanduser( '~/.wat.conf' )

def repoConfigSectionName( alias ):
    return 'repo %s' % alias

def writeConfig( config ):
    with open( CONFIG_FILE, 'wb' ) as cf:
        config.write( cf )

def getWatFiles( config, repo=None ):
    files = []
    for section in config.sections():
        if repo is None or section.replace( 'repo ', '' ) == repo:
            d = config.get( section, 'dir' )
            files.extend( [ os.path.join( d, f ) for f in os.listdir( d ) \
                            if os.path.isfile( os.path.join( d, f ) ) and f.endswith( '.wat' ) ] )
    return files

# http://misc.flogisoft.com/bash/tip_colors_and_formatting
TERM_RESET = '\033[0m'
TERM_BOLD = '\033[1m'
TERM_BLUE = '\033[34m'
TERM_LIGHT_GREEN = '\033[92m'
TERM_LIGHT_MAGENTA = '\033[95m'
TERM_LIGHT_CYAN = '\033[96m'

TERM_KEYWORD_COLOR = TERM_BLUE

specialSymbols = {
        '[T]': TERM_LIGHT_MAGENTA + TERM_BOLD,
        '[C]': TERM_LIGHT_CYAN,
        '[N]': TERM_RESET
    }

def formatText( text, withColor=True ):
    for k, v in specialSymbols.iteritems():
        if withColor:
            text = text.replace( k, v )
        else:
            text = text.replace( k, '' )
    return text

def topicNameFromFile( filename ):
    return os.path.split( filename )[ 1 ].replace( '.wat', '' )

class WatEntry( object ):
    def __init__( self ):
        self.text = ''
        self.keywords = []

    def matchesKeywords( self, keywords ):
        ''' Loose keyword matching. eg. "file" will match "files" '''
        for kw in keywords:
            matched = False
            for skw in self.keywords:
                if kw.lower() in skw.lower():
                    matched = True
                    break
            if not matched:
                return False
        return True

    def matchesPattern( self, regex, ignoreCase=False ):
        flags = re.IGNORECASE if ignoreCase else 0
        for kw in self.keywords:
            if re.search( regex, kw, flags=flags ):
                return True
        return re.search( regex, self.text, flags=flags )

    def printEntry( self, withColor=True ):
        print formatText( self.text, withColor=withColor )
        if len( self.keywords ) > 0:
            startFormat = TERM_KEYWORD_COLOR if withColor else ''
            endFormat = TERM_RESET if withColor else ''
            print '\n    %s%s%s' % ( startFormat, ', '.join( self.keywords ), endFormat )

def parseWatFile( filename ):
    with open( filename, 'r' ) as watfile:
        entries = []
        currentEntry = None
        inEntry = False
        for line in watfile.readlines():
            if line.strip().startswith( '[ENTRY]' ):
                inEntry = True
                currentEntry = WatEntry()
                entries.append( currentEntry )
                currentEntry.keywords = [ s for s in line.replace('[ENTRY]', '').replace( '\n', '')\
                                        .split( ' ' ) if len( s ) > 0 ]
            elif inEntry:
                currentEntry.text += line

        for i in range( len( entries ) ):
            entries[ i ].text = entries[ i ].text.rstrip()
        return entries

def main():
    argparser = argparse.ArgumentParser( prog='wat',
            description='Searches and provides minimal management interface to personal notes'
                        ' and examples. Items are keyworded, and stored in configurable repos. '
                        'See the examples directory for topic styling.')

    argparser.add_argument( 'topic', type=str, nargs='?',
                            help="The topic to search for entries." )
    argparser.add_argument( '--add-repo', metavar=( 'ALIAS', 'DIRECTORY' ), type=str, nargs=2,
                            help='Add a locally cloned git repo as a wat repo. The directory '
                                 ' can be a subdirectory in a git repo.')
    argparser.add_argument( '--remove-repo', metavar='ALIAS', type=str,
                            help='Remove a wat repo.' )
    argparser.add_argument( '--list-repos', action='store_true',
                            help='List configured repos.' )
    argparser.add_argument( '--list-topics', action='store_true',
                            help='List all topics. May be filtered with --repo and --regex' )
    argparser.add_argument( '--keywords', '-k', metavar='KEYWORD', type=str, nargs='+',
                            help='Show entries which match all keywords.' )
    argparser.add_argument( '--regex', '-r', metavar='PATTERN', type=str,
                            help='Show entries which have text or keywords that match the '
                                 'regular expression.' )
    argparser.add_argument( '--ignore-case', '-i', action='store_true',
                            help='Ingore case in a regex search.' )
    argparser.add_argument( '--repo', metavar='ALIAS', type=str,
                            help='Search in a specific repo.' )
    argparser.add_argument( '--no-color', action='store_true',
                            help='Do not output with tty formatting.' )
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
        if args.repo and not config.has_section( repoConfigSectionName( args.repo ) ):
            print 'No repos named %s' % args.repo
            quit()
        watFiles = getWatFiles( config, repo=args.repo )
        if args.topic:
            watFiles = filter( lambda wf: topicNameFromFile( wf ) == args.topic, watFiles )
            if len( watFiles ) == 0:
                print 'No topics found named %s' % args.topic
                quit()
        elif args.keywords is None and args.regex is None and not args.list_topics:
            argparser.print_usage()
            print 'error: expected topic or --keywords or --regex'
            quit()

        if args.list_topics:
            topics = set( topicNameFromFile( wf ) for wf in watFiles )
            topics = [ t for t in topics ]
            topics.sort()
            for topic in topics:
                print topic
        else:
            entries = []
            for f in watFiles:
                entries.extend( parseWatFile( f ) )

            if args.keywords:
                entries = filter( lambda e: e.matchesKeywords( args.keywords ), entries )

            if args.regex:
                entries = filter(
                        lambda e: e.matchesPattern( args.regex, ignoreCase=args.ignore_case ),
                        entries )

            for entry in entries:
                entry.printEntry( withColor=not args.no_color )
                print ''

if __name__ == '__main__':
    main()
