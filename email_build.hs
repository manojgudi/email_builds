{-# LANGUAGE OverloadedStrings #-}

import Data.Text (Text)
import qualified Data.Text.Lazy.Internal as LInternal
import qualified Data.Text.Internal as Internal

import HSH (run)
import Network.Mail.Client.Gmail (sendGmail)
import Network.Mail.Mime (Address)

import GetParams (LazyIntText, IntText)
type LazyIntText = LInternal.Text
type IntText = Internal.Text
{-
data EmailParam = 
    EmailParam { emailId    :: !Text
                ,password   :: !Text
        } deriving Show
-}




{-
 - Lifted from getAllCommitHash oldestLine project
 - is this LazyIO?
 - -}
getChangeLog :: String -> Int -> IO [String]
getChangeLog currentDir numberOfHeads = do
    content <- run $ "git -C " ++ currentDir ++ " --no-pager log --pretty=oneline --abbrev-commit" :: IO String
    let changeLog = take numberOfHeads $ lines content
    return changeLog


emailBuild :: LazyIntText -> LazyIntText -> Address -> [Address] -> [Address] -> IntText -> LazyIntText -> [FilePath] -> Int -> IO ()
emailBuild from password sender to cc subject emailBody attachmentList timeout = sendGmail from password sender to cc [] subject emailBody attachmentList timeout

--a = sendGmail "senderemail" "senderpass" (Address (Just "Alice") "email1") [Address (Just "Bob") "email2"] [] [] "Excel Spreadsheet" "Hi Bob,\n\nThe Excel spreadsheet is attached.\n\nRegards,\n\nAlice" ["README.md"] 10000000
