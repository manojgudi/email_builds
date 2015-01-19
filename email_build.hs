{-# LANGUAGE OverloadedStrings #-}

import Control.Monad
import Control.Applicative

import Data.Text (Text)
import qualified Data.Text.Lazy as DTL

import HSH (run)
import Network.Mail.Client.Gmail (sendGmail)
import Network.Mail.Mime

import GetParams

{-
 - Lifted from getAllCommitHash oldestLine project
 - is this LazyIO?
 - 
 - TODO
 - Put a provision to link all the commits to links in bitbucket repo
 - -}

getChangeLog :: String -> Int -> IO [String]
getChangeLog repoPath numberOfHeads = do
    content <- run $ "git -C " ++ repoPath ++ " --no-pager log --pretty=oneline --abbrev-commit" :: IO String
    let changeLog = take numberOfHeads $ lines content
    return changeLog

{-
 - Takes username and from field from EmailParam and constructs an Address type data
 - -}
formAddress :: Text -> LazyIntText -> Address
formAddress uname from = Address (Just uname) (DTL.toStrict from)

{-
 - Takes emailBody from EmailParam Data appends changeLog and returns it
 - -}
prepareBody :: EmailParam -> IO String
prepareBody param = do
    changeLog <- getChangeLog (repoPath param) (nCommits param)
    return $ (DTL.unpack.emailBody) param ++ "\nChangeLog:\n\n" ++ (foldl1 (\x y -> x ++ "\n" ++ y) changeLog) ++ "\n\n" ++ (signature param)


{-
 - Takes EmailParam data and plugs it in sendGmail function
 - -}
emailBuild :: EmailParam -> IO()
emailBuild param = do
    emailContent <- prepareBody param
    sendGmail (from param) (passwd param) (formAddress (uname param) (from param)) (map (formAddress "") (to param)) (map (formAddress "") (cc param)) [] (subject param) (DTL.pack emailContent) (attachment param) (timeout param)

main :: IO ()
main = do
    -- The first argument is path to emailParam json file
    args <- getArgs

    -- Get JSON and decode
    d <- getData (args !! 0)
    emailBuild d
    putStrLn "Emailed successfully.."
