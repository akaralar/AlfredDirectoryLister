# Alfred List Folders Workflow
This is an [Alfred](http://www.alfredapp.com) workflow written 
in Swift to access the most recent files and folders in the 
given directory.

The items are sorted in decreasing order based on the time they
are added to the folder. The item is filtered by testing whether
the query is a subsequence (need not be consecutive) of it. By 
default, the workflow is invoked by "d<space>".

There are four operations on the selected item:

1. open with default application (default)
2. reveal in Finder (holding "cmd" key)
3. delete (holding "ctrl" key)
4. move to trash (holding "option" key)

The input parameters to the script, which can also be seen by 
running `directory-lister --help` in the workflow folder, are 
as follows:

```no-highligt
OPTIONS:
  -d, --dir <dir>         Directory to list (default: ~/Downloads)
  -q, --query <query>     Query for fuzzy matching of filenames
  -m, --max <max>         Maximum items to return. If zero or negative, all items will be returned (default: 0)
  -i, --include-dir       Returns the input directory as the first item in the list
  -c, --case-insensitive  Case-insensitive matching of query
```

# Installation

1. Clone the repo.
2. Double-click the "AlfredListFolders.alfredworkflow" to install.

# Building

You need to have [Swift](https://www.swift.org/install/) installed in your system, then `cd` into the repo folder and 
run:
```bash
swift build -c release
```

This builds the binary used in the script filter and places it in `./.build/release/directory-lister`

# Acknowledgement

This workflow is heavily inspired by [Recent Downloads Workflow](https://github.com/ddjfreedom/recent-downloads-alfred-v2/).
While that workflow has many useful features that this workflow doesn't have, the performance was sometimes 
unsatisfactory. I also wanted to have the same functionality for other folders and I wanted to have the main directory 
as the topmost result. That's how this workflow came to be. 

