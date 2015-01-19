{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module GetParams where

import Control.Monad
import Control.Applicative

import qualified Data.Text as DT
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
                ,uname          :: DT.Text
                ,passwd         :: LazyIntText
--                ,sender         :: Address
                ,to             :: ![LazyIntText] --[Address]
                ,cc             :: ![LazyIntText] --[Address]
                ,subject        :: IntText
                ,emailBody      :: LazyIntText
                ,attachment     :: ![FilePath] --[FilePath]
                ,signature      :: !String
                ,repoPath       :: !FilePath
                ,nCommits       :: Int
                ,timeout        :: Int
                } deriving (Show)

{- I know generics will remove following code
 - But I want to explicity write this one time
 -}
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
                   <*> v .: "signature"
                   <*> v .: "repoPath"
                   <*> v .: "nCommits"
                   <*> v .: "timeout"

    parseJSON _ = mzero

instance ToJSON EmailParam where
    toJSON (EmailParam from uname passwd to cc subject emailBody attachment signature repoPath nCommits timeout) =
        object [ "from"       .= from
                ,"uname"      .= uname
                ,"passwd"     .= passwd
                ,"to"         .= to
                ,"cc"         .= cc
                ,"subject"    .= subject
                ,"body"       .= emailBody
                ,"attachment" .= attachment
                ,"signature"  .= signature
                ,"repoPath"   .= repoPath
                ,"nCommits"   .= nCommits
                ,"timeout"    .= timeout
                ]

getJSON :: FilePath -> IO B.ByteString
getJSON jsonFile = B.readFile jsonFile

getData :: FilePath -> IO (EmailParam)
getData jsonPath = do
    d <- (eitherDecode <$> (getJSON jsonPath)) :: IO (Either String EmailParam)
    return (rights [d] !! 0)

{-
main :: IO (Either String EmailParam)
main = do
--Get JSON and decode
    d <- (eitherDecode <$> getJSON) :: IO (Either String EmailParam)
    return d

    case d of 
        Left err -> putStrLn err
        Right ps -> return ps
-}
