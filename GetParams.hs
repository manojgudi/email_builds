{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
import Control.Monad
import Control.Applicative

import Data.Text
import Data.Either (rights)
import qualified Data.Text.Lazy.Internal as LInternal
import qualified Data.Text.Internal as Internal

import Data.Aeson
import qualified Data.ByteString.Lazy as B

import Network.Mail.Mime (Address)

type LazyIntText = LInternal.Text
type IntText = Internal.Text

data EmailParam = 
     EmailParam {from           :: LazyIntText
                ,uname          :: LazyIntText
                ,passwd         :: LazyIntText
--                ,sender         :: Address
                ,to             :: !Array --[Address]
                ,cc             :: !Array --[Address]
                ,subject        :: IntText
                ,emailBody      :: LazyIntText
                ,attachment     :: !Array --[FilePath]
                ,repoPath       :: LazyIntText
                ,nCommits       :: Int
                ,timeout        :: Int
                } deriving (Show)

--instance FromJSON EmailParam
--instance ToJSON EmailParam

instance FromJSON EmailParam where
    parseJSON (Object v) =
        EmailParam <$> v .: "from"
                   <*> v .: "uname"
                   <*> v .: "passwd"
                   <*> v .: "to"
                   <*> v .: "cc"
                   <*> v .: "subject"
                   <*> v .: "body"
                   <*> v .: "attachment"
                   <*> v .: "repoPath"
                   <*> v .: "nCommits"
                   <*> v .: "timeout"

    parseJSON _ = mzero

instance ToJSON EmailParam where
    toJSON (EmailParam from uname passwd to cc subject emailBody attachment repoPath nCommits timeout) =
        object [ "from"      .= from
                ,"uname"     .= uname
                ,"passwd"    .= passwd
                ,"to"        .= to
                ,"cc"        .= cc
                ,"subject"   .= subject
                ,"body"      .= emailBody
                ,"attachment".= attachment
                ,"repoPath"  .= repoPath
                ,"nCommits"  .= nCommits
                ,"timeout"   .= timeout
                ]

jsonFile :: FilePath
jsonFile = "email_param.json"

getJSON :: IO B.ByteString
getJSON = B.readFile jsonFile

getData :: IO (EmailParam)
getData = do
    d <- (eitherDecode <$> getJSON) :: IO (Either String EmailParam)
    return (rights [d] !! 0)

main :: IO (Either String EmailParam)
main = do
--Get JSON and decode
    d <- (eitherDecode <$> getJSON) :: IO (Either String EmailParam)
    return d
{-    case d of 
        Left err -> putStrLn err
        Right ps -> return ps
-}
