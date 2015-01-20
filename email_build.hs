{-# LANGUAGE OverloadedStrings #-}

import Control.Monad
import Control.Applicative

import Data.Text (Text)
import qualified Data.Text.Lazy as DTL

import HSH (run)
import Network.Mail.Client.Gmail (sendGmail)
import Network.Mail.Mime
import System.Environment (getArgs)
import Data.String.Utils (split)

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
 - Format the entire md5sum output to look like this
 - 123312657984..  FILENAME (without path prefix)
 - -}
formatSum :: String -> String
formatSum md5sum = last (split "/" (wordsmd5 !! 1)) ++ " -> " ++ (wordsmd5 !! 0)
    where wordsmd5 = words md5sum

{-
 - Get the md5sum of the file
 - Get it from terminal(quick and dirty) instead of using another library
 - -}
getmd5sum :: FilePath -> IO String
getmd5sum file = do
    md5sum <- run $ "md5sum " ++ file
    return $ formatSum md5sum

{-
 - Takes emailBody from EmailParam Data appends changeLog and returns it
 -}
prepareBody :: EmailParam -> IO String
prepareBody param = do
    changeLog <- getChangeLog (repoPath param) (nCommits param)
    fileSums <- (liftM  unlines) $ mapM getmd5sum (attachment param)
    return $ (DTL.unpack.emailBody) param ++ "\nChangeLog:\n\n" ++ (foldl1 (\x y -> x ++ "\n" ++ y) changeLog) ++ "\n\nCHECKSUMS\n" ++ fileSums ++ "\n\n" ++ (signature param)


sendSingleMail :: EmailParam -> String -> LazyIntText -> IO()
sendSingleMail param emailContent toId = sendGmail (from param) (passwd param) (formAddress (uname param) (from param)) (map (formAddress "") [toId]) (map (formAddress "") (cc param)) [] (subject param) (DTL.pack emailContent) (attachment param) (timeout param)

{-
 - Takes EmailParam data and plugs it in sendGmail function
 - -}
emailBuild :: EmailParam -> IO()
emailBuild param = do
    emailContent <- prepareBody param
    mapM_ (sendSingleMail param emailContent) (to param)

main :: IO ()
main = do
    -- The first argument is path to emailParam json file
    args <- getArgs

    -- Get JSON and decode
    d <- getData (args !! 0)
    emailBuild d
    putStrLn "Emailed successfully.."
