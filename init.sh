#!/bin/bash

/usr/bin/supervisord&
gearmand&
/bin/bash
