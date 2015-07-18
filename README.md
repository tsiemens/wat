# wat
A personalized supplement to man pages, similar to bro pages.

Allows you to add different repositories of notes, cheatsheets, or just whatever, that you can easily query from the command line.
Great for managing notes for confidential tools used at work.
Don't worry about overlapping topics either. Have both personal notes for vi and some crazy plugins at work? No problem! Both your work-repo/vi.wat and personal-repo/vi.wat entries will be combined while searching!

## Setup
1. Copy wat into your path
2. Add your first wat repo (this will be saved to ~/.wat/conf) by running `wat --add-repo myrepoalias /path/to/repo`.
  If you cloned this project, you can use the path to the examples directory in this project as your first repo.
3. Start querying your wat entries!
  ```
  $ wat wat -k format
  # Add special formatting to wat file
  Some strings surrounded by [] represent special formatting or sections in wat files.

      SUMMARY     Text summarizing the file's topic
      ENTRY       A sub-section on the topic. Words on this line are keywords for the entry.
      T           Stype text as title
      C           Style text as code
      N           Style text normally

      files, formatting, style
  ```
  And you can't see it from the markdown, but it's colored nicely as well!
