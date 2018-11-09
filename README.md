 # playground

[![Build Status](https://travis-ci.org/christianclarke/playground.svg?branch=master)](https://travis-ci.org/christianclarke/playground)

  

A simple Ruby Sinatra application, with the following endpoints

 - /
 
    Calculates a series of Fibonacci integers
 
 - /metrics
 
    Prometheus exposing the following metric : playground_request{fibonacci_sequence="hit_count"}
 
 - /healthz
 
    Returns a HTTP 200 as healthcheck endpoint
