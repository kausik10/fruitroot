{-# LANGUAGE QuasiQuotes #-}

module Writer(
  makeTitle
  , genHtml
  , writeList
  , htmlBlock
             ) where

import Text.RawString.QQ
import Parser
import Data.List(intercalate)

genHtml metadata content =
            "<html>\n"
            <> htmlHead metadata
            <> "\n<body>"
            <> makeTitle (head content)
            <> makeAuthor metadata
            <> "\n<main> <article>\n"
            <> htmlBody (tail content)
            <> "\n</article> </main>\n"
            <> "\n</body>\n</html>"

headStatic = [r|
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Martian+Mono:wght@100..800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="styles.css">
|]


htmlHead (Meta title _)= "<head>"
          <> headStatic
          <> "<title>"
          <> title
          <> "</title>"
          <>"</head>"

htmlBody [] = ""
htmlBody (x:xs) = htmlBlock x <> "\n" <> htmlBody xs

makeTitle :: Elem -> String
makeTitle (Header 1  content) = "<header>"
                        <> htmlBlock (Header 1 content)
                        <> "</header>"
                        <> "\n"

makeTitle (_) = "" -- HACK: removes empty paragraphs that are on upon empty \n

makeAuthor (Meta _ author) = "<h3>\n"
                             <> "Author: "
                             <> author
                             <> "</h3>"
                             <> "\n"

htmlBlock (Paragraph content) = "<p>"
                                <> htmlInlines content
                                <> "</p>"

-- TODO: Maybe add sytax highlighthing for popular langs?
htmlBlock (Code _ content) = "<pre> <code>"
                             <> htmlInlines content
                             <> "</code> </pre>"

htmlBlock (Quote contents) = "<blockquote>\n"
                            <> intercalate "\n" (map writeQuote contents)
                            <> "\n</blockquote>"
                            where writeQuote (Paragraph c) = htmlInlines c
                                                             <> "<br>"

htmlBlock (Header l content)  = "<h"<>show l<>">"
                          <> htmlInlines content
                          <> "</h"<>show l <>">"

htmlBlock (List contents)  =
            case head contents of
              (Numbered _  _) -> "<ol>\n"
                                 <> writeListCont contents
                                 <> "</ol>"
              (Bulleted _)    -> "<ul>\n"
                                 <> writeListCont contents
                                 <> "</ul>"


writeListCont [] = ""
writeListCont (x:xs) = "<li>"
                       <> writeList x
                       <> "</li>\n"
                       <> writeListCont xs

writeList (Numbered _ content) = htmlBlock content
writeList (Bulleted content)   = htmlBlock content

htmlInlines [] = ""
htmlInlines (x:xs) = htmlInline x <> htmlInlines xs

htmlInline (Literal content) = content
htmlInline (Emph    content) = "<em>"
                        <> htmlInlines content
                        <> "</em>"

htmlInline (Strong  content) = "<strong>"
                        <> htmlInlines content
                        <> "</strong>"
