[ENTRY] summary
[T]# wat Summary[N]
A personalized supplement to man pages, similar to bro pages.
Supports personal git repos or plain directories of wat files.
Use topics, keywords and even regex to search through your notes and hints.

[ENTRY] show topic
[T]# Show all wat entries for a topic[N]
In this case, the wat topic

    [C]$ wat wat[N]

[ENTRY] add repos
[T]# Adding wat repos[N]
wat allows you to add many different directories or repos containing .wat files.
Each .wat file should be on a topic, and named as such. So wat.wat is on the topic of 'wat'.
Each topic file can contain many entries, each with its own keywords for searching.

    [C]$ wat --add-repo myrepoalias /path/to/repo[N]

[ENTRY] search find query
[T]# Searching wat entries[N]
Searching wat can be done with --keywords or --regex.
--regex will try to match text and keywords. It can be combined with the --ignore-case option.
--keywords will only try to match on keywords, but do not need to be a full match. ie. 'fo' will match the keyword 'foo'

    [C]$ wat [topic] -k key1 key2 -r regexString[N]

[ENTRY] files formatting style
[T]# Add special formatting to wat file[N]
Some strings surrounded by [] represent special formatting or sections in wat files.

    SUMMARY     Text summarizing the file's topic
    ENTRY       A sub-section on the topic. Words on this line are keywords for the entry.
    T           Stype text as title
    C           Style text as code
    N           Style text normally
