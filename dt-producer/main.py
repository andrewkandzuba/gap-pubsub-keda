import os
import json
import time
from google.cloud import pubsub_v1

# Configuration
PROJECT_ID = os.environ.get("PROJECT_ID")
TOPIC_ID = "dt-message"

# Initialize the Publisher client
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)

def produce_messages():
    """Produces simple JSON messages to a Pub/Sub topic."""
    message_id = 0
    while True:
        message_id += 1
        message_data = {
            "message_id": message_id,
            "text": f"This is message number {message_id}",
            "timestamp": time.time()
        }

        # Data must be a bytestring
        data = json.dumps(message_data).encode("utf-8")

        # Publish the message
        future = publisher.publish(topic_path, data)
        print(f"Published message ID: {future.result()}")

        # Wait for a short interval before sending the next message
        time.sleep(1)

if __name__ == "__main__":
    if not PROJECT_ID:
        raise ValueError("The PROJECT_ID environment variable must be set.")

    print(f"Starting producer for topic: {topic_path}")
    produce_messages()

