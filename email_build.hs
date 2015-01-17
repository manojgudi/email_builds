{-# LANGUAGE OverloadedStrings #-}

import HSH (run)
import Network.Mail.Client.Gmail
import Network.Mail.Mime

{-
 - Lifted from getAllCommitHash oldestLine project
 - is this LazyIO?
 - -}
getChangeLog :: String -> Int -> IO [String]
getChangeLog currentDir numberOfHeads = do
    content <- run $ "git -C " ++ currentDir ++ " --no-pager log --pretty=oneline --abbrev-commit" :: IO String
    let changeLog = take numberOfHeads $ lines content
    return changeLog

emailBuild :: String -> String -> String -> [String] -> Integer -> IO ()
emailBuild emailId password emailBody attachmentList timeout = sendGmail emailId password (Address (Just "Alice") "email1") [Address (Just "Bob") "email2"] [] [] emailBody attachmentList timeout

--a = sendGmail "senderemail" "senderpass" (Address (Just "Alice") "email1") [Address (Just "Bob") "email2"] [] [] "Excel Spreadsheet" "Hi Bob,\n\nThe Excel spreadsheet is attached.\n\nRegards,\n\nAlice" ["README.md"] 10000000
