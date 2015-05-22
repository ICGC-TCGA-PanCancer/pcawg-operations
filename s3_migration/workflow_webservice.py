#!/usr/bin/python

# Redirect behind apache

import logging
import sqlite3
import BaseHTTPServer
import time
import uuid
import os

PORT_NUMBER=10101
HOST_NAME='127.0.0.1'

def SetupLogging(filename,level=logging.INFO):
    """ Logging Module Interface. """
    logging.basicConfig(filename=filename,level=level)

class StoreAndForward(object):
    """ Database Interface Class. """
    def __init__(self, filename="store-and-forward.db"):
        if not os.path.exists(filename):
            logging.info("Creating database: %f" % filename)
            conn = sqlite3.connect(filename)
            c = conn.cursor()
            c.execute("CREATE TABLE SUCCESS(analysisID CHAR(36));")
            c.execute("CREATE TABLE FAILURE(analysisID CHAR(36));")
            c.close()
            conn.commit()
            conn.close()
        self.filename=filename
    def success(self, uuid):
        logging.info("Insertion into SUCCESS: %s" % (uuid))
        conn = sqlite3.connect(self.filename)
        c = conn.cursor()
        c.execute("INSERT INTO SUCCESS (analysisID) VALUES ('%s');" % (uuid))
        c.execute("DELETE FROM FAILURE WHERE 'analysisID'='%s';" % (uuid))
        c.close()
        conn.commit()
        conn.close()
    def fail(self, uuid):
        logging.info("Insertion into FAILURE: %s" % (uuid))
        conn = sqlite3.connect(self.filename)
        c = conn.cursor()
        c.execute("INSERT INTO FAILURE ('analysisID') VALUES ('%s');" % (uuid))
        c.execute("DELETE FROM SUCCESS WHERE 'analysisID'='%s';" % (uuid))
        c.close()
        conn.commit()
        conn.close()
    def dump(self):
        logging.info("Dumping database results: %s" % (uuid))
        conn = sqlite3.connect(self.filename)
        c = conn.cursor()
        results = "\nSUCCESS:" 
        for row in c.execute('SELECT * FROM SUCCESS'):
            results = results + "\n%s" % (row)
        results += "\n\nFAIL:" 
        for row in c.execute('SELECT * FROM FAILURE'):
            results = results + "\n%s" % (row)    
        c.close()
        conn.close()
        return results
    
class MyHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    """ Handler for the listener. """
    def do_HEAD(s):
         s.send_response(200)
         s.send_header("Content-type", "text/html")
         s.end_headers()
    def do_GET(s):
        """Respond to a GET request."""
        s.send_response(200)
        s.send_header("Content-type", "text/plain")
        s.end_headers()
        s.wfile.write("Path: %s\n" % (s.path))
        if len(s.path.split("/")) == 2:
            route = s.path.split("/")[1]
            uuid = ""
        else:
            route, uuid = s.path.split("/")[1], s.path.split("/")[2]
        s.wfile.write("Route: %s\n" % (route))
        HandleRoute(route, uuid, s)
        
def HandleRoute(route, uuid, s):
    """ Routing for the listener. """
    if route == "success":
        if validUUID(uuid):
            db.success(uuid)
    if route == "fail":
        if validUUID(uuid):
            db.fail(uuid)
    if route == "dump":
        s.wfile.write("\nDATABASE DUMP")
        s.wfile.write("%s" % (db.dump()))
        
def validUUID(uuid_string):
    """ Validate a UUID. """
    try:
        val = uuid.UUID(uuid_string, version=4)
    except ValueError:
        return False
    return True

def main():
    print time.asctime(), "Server Starts - %s:%s" % (HOST_NAME, PORT_NUMBER)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print time.asctime(), "Server Stops - %s:%s" % (HOST_NAME, PORT_NUMBER)
    
     
if __name__ == '__main__':
    SetupLogging('store-and-forward.log')
    db = StoreAndForward()
    server_class = BaseHTTPServer.HTTPServer
    httpd = server_class((HOST_NAME, PORT_NUMBER), MyHandler)
    main()
    
