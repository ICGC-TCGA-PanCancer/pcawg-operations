#!/usr/bin/python

# Redirect behind apache

# Added query strings to support the fields Junjun has requested in Jira Ticket: https://jira.oicr.on.ca/browse/PANCANCER-702
# TO REPORT WORKFLOW SUCCESS OR FAILURE:
# curl pancancer.info/:virtualhost?action=[ success/fail/dump ]workflow=[ workflow name ]&gnos=[ gnos location ]&date=[ date in unix format ]&analysisID=[ analysis ID in question]

import logging
import BaseHTTPServer
import os
import sqlite3
import sys
import time
import uuid
import urlparse


# Constants
PORT_NUMBER=10101
HOST_NAME='127.0.0.1'


def SetupLogging(filename,level=logging.INFO):
    """ Logging Module Interface.
    Args:
        filename:   The filename to log to.
        level:      The logging level desired.
    Returns:
        None
    """
    logging.basicConfig(filename=filename,level=level)
    return None


class StoreAndForward(object):
    """ Database Interface Class. """
    def __init__(self, filename="workflow_runs.db"):
        if not os.path.exists(filename):
            logging.info("Creating database: %s" % filename)
            conn = sqlite3.connect(filename)
            c = conn.cursor()
            c.execute("CREATE TABLE SUCCESS(analysisID CHAR(36), "
                      "workflow TEXT, "
                      "gnos TEXT, "
                      "date TEXT);")
            c.close()
            conn.commit()
            conn.close()
        self.filename=filename
        
    def success(self, query):
        """ Processes successful entries into the database. "
        Args:
            query:  The query string represented as a dictionary.
        Returns:
            None
        """
        uuid = query['uuid'][0]
        workflow = query['workflow'][0]
        gnos = query['gnos'][0]
        date = query['date'][0]
        logging.info("Insertion into SUCCESS: %s" % (uuid))
        conn = sqlite3.connect(self.filename)
        c = conn.cursor()
        c.execute("INSERT INTO SUCCESS (workflow, analysisID, date, gnos) VALUES ('%s','%s','%s','%s');" % (workflow, uuid, date, gnos))
        c.close()
        conn.commit()
        conn.close()

    def fail(self, query):
        """ Processes failed entries into the database.
        Args:
            query:  The query string represented as a dictionary.
        Returns:
            None
        """
        uuid = query['uuid'][0]
        workflow = query['workflow'][0]
        logging.info("Insertion into FAILURE: %s" % (uuid))
        conn = sqlite3.connect(self.filename)
        c = conn.cursor()
        c.execute("DELETE FROM SUCCESS WHERE workflow='%s' AND analysisID='%s';" % (workflow, uuid))
        c.close()
        conn.commit()
        conn.close()

    def dump(self, query):
        """ Dumps the complete output of the database, based on the query string.
        Args:
            query:  The query string represented as a dictionary.
        Returns:
            None
        """
        workflow = query['workflow'][0]
        logging.info("Dumping database results: %s" % (workflow))
        results = ""
        conn = sqlite3.connect(self.filename)
        c = conn.cursor()
        for row in c.execute("SELECT * FROM SUCCESS WHERE workflow='%s'" % (workflow)):
            for col in row:
                results += "%s\t" % ( str(col) )
            results += "\n"
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
        parsed = urlparse.urlparse(s.path)
        query = urlparse.parse_qs(parsed.query)
 
        if 'action' not in query:
            print query
            s.wfile.write("Improperly formatted url.\n")
            return
        
        if query['action'][0] == 'dump':
            print query
            if query['workflow'] != '':
                HandleRoute('dump', query, s)
        elif 'uuid' not in query or 'workflow' not in query or 'uuid' not in query or 'gnos' not in query:
            print query
            s.wfile.write("Improperly formatted url.\n")
            return
        elif not validUUID(query['uuid'][0] ):
            s.wfile.write("Improperly formatted UUID.\n")
            return
        elif query['action'][0] == 'success':
            if (query['workflow'][0] != '' and query['uuid'][0] != ''
                and query['date'][0] != '' and query['gnos'][0] != ''):
                HandleRoute('success', query, s)
        elif query['action'][0] == 'fail':
            if (query['workflow'][0] != '' and query['uuid'][0] != ''
                and query['date'][0] != '' and query['gnos'][0] != ''):
                HandleRoute('fail', query, s)

        
def HandleRoute(route, query, s):
    """ Routing for the listener.
    Args:
        route:      A string indicating the route to process.
        query:      The query string represented as a dictionary.
        s:          The request object passed from webserver.
    Returns:
        None
    """
    if route == "success":
        db.success(query)
        s.wfile.write("ok")
    if route == "fail":
        db.fail(query)
        s.wfile.write("ok")
    if route == "dump":
        s.wfile.write("%s" % (db.dump(query)))

        
def validUUID(uuid_string):
    """ Validate a UUID.
    Args:
        uuid_string:    A uuid in string format.
    Returns:
        A boolean indicating validitiy.
    """
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
    
