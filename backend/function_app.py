import azure.functions as func
from azure.data.tables import TableServiceClient, UpdateMode
import os
import logging
import json
import traceback
from datetime import datetime, timezone

app = func.FunctionApp()

# Set logging level
logging.basicConfig(level=logging.INFO)

@app.route(route="VisitorCounter", auth_level=func.AuthLevel.ANONYMOUS)
def VisitorCounter(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('===VISITOR COUNTER FUNCTION CALLED ===')
    
    # Get visitor ID from query parameter
    visitor_id = req.params.get('visitorId')
    if not visitor_id:
        return func.HttpResponse(
            json.dumps({"error": "visitorId parameter is required"}),
            status_code=400,
            headers={"Content-Type": "application/json"}
        )
    
    # Debug: Check environment variables
    cosmos_endpoint = os.environ.get("COSMOS_ENDPOINT")
    cosmos_key      = os.environ.get("COSMOS_KEY")
    
    logging.info(f"Cosmos endpoint: {cosmos_endpoint}")
    logging.info(f"Visitor ID: {visitor_id}")
    
    try:
        # Extract account name from endpoint
        account_name = cosmos_endpoint.split('.')[0].replace('https://', '').replace('http://', '')

        # Build  Table API endpoint  
        table_endpoint = f"https://{account_name}.table.cosmos.azure.com:443/"

        # Build connection string for Table API
        conn_str = f"DefaultEndpointsProtocol=https;AccountName={account_name};AccountKey={cosmos_key};TableEndpoint={table_endpoint}"
        
        logging.info(f"Account name: {account_name}")
        logging.info(f"Table endpoint: {table_endpoint}")

        logging.info("Creating table service client...")
        table_service = TableServiceClient.from_connection_string(conn_str)
        
        # Get table clients for both counter and visitors
        counter_table = table_service.get_table_client(table_name="VisitorCounter")
        visitors_table = table_service.get_table_client(table_name="Visitors")
        
        # Check if this visitor has been seen before
        is_new_visitor = False
        try:
            visitor_entity = visitors_table.get_entity(
                partition_key="visitors",
                row_key=visitor_id
            )
            logging.info(f"Returning visitor: {visitor_id}")
        except Exception:
            # New visitor
            is_new_visitor = True
            logging.info(f"New visitor: {visitor_id}")
            
            # Record the new visitor
            new_visitor = {
                "PartitionKey": "visitors",
                "RowKey": visitor_id,
                "firstVisit": datetime.now(timezone.utc).isoformat(),
                "lastVisit": datetime.now(timezone.utc).isoformat(),
                "visitCount": 1
            }
            visitors_table.upsert_entity(entity=new_visitor)
            
        # Get current unique visitor count
        try:
            counter_entity = counter_table.get_entity(
                partition_key="counter",
                row_key="uniqueVisitors"
            )
            current_count = counter_entity.get("count", 0)
        except Exception:
            # First time, create the counter
            current_count = 0
            
        # Only increment if it's a new visitor
        if is_new_visitor:
            current_count += 1
            
            # Update the unique visitors counter
            counter_entity = {
                "PartitionKey": "counter",
                "RowKey": "uniqueVisitors",
                "count": current_count,
                "lastUpdated": datetime.now(timezone.utc).isoformat()
            }
            counter_table.upsert_entity(entity=counter_entity, mode=UpdateMode.REPLACE)
        else:
            # Update last visit time for returning visitor
            visitor_entity["lastVisit"] = datetime.now(timezone.utc).isoformat()
            visitor_entity["visitCount"] = visitor_entity.get("visitCount", 1) + 1
            visitors_table.upsert_entity(entity=visitor_entity, mode=UpdateMode.MERGE)
        
        # Also track total page views (optional)
        try:
            views_entity = counter_table.get_entity(
                partition_key="counter",
                row_key="totalViews"
            )
            total_views = views_entity.get("count", 0) + 1
        except Exception:
            total_views = 1
            
        views_entity = {
            "PartitionKey": "counter",
            "RowKey": "totalViews",
            "count": total_views
        }
        counter_table.upsert_entity(entity=views_entity, mode=UpdateMode.REPLACE)
        
        return func.HttpResponse(
            json.dumps({
                "uniqueVisitors": current_count,
                "totalViews": total_views,
                "isNewVisitor": is_new_visitor,
                "count": current_count  # Keep for backward compatibility
            }),
            status_code=200,
            headers={
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            }
        )
        
    except Exception as e:
        # Get detailed error information
        error_details = {
            "error": str(e),
            "type": type(e).__name__,
            "traceback": traceback.format_exc()
        }
        logging.error(f"Detailed error: {json.dumps(error_details)}")
        
        return func.HttpResponse(
            json.dumps(error_details),
            status_code=500,
            headers={"Content-Type": "application/json"}
        )