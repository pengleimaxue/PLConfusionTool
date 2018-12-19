#!/bin/bash
project_path=$(cd `dirname $0`; pwd)
echo $project_path'/ruby.rb'
ruby  $project_path'/ruby.rb'
