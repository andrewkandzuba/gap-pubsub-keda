import os
import time
from google.cloud import pubsub_v1

# Configuration
PROJECT_ID = os.environ.get("PROJECT_ID")
TOPIC_ID = "dt-message"
SUBSCRIPTION_ID = "dt-message-subscription"

# Initialize the Subscriber client
subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path(PROJECT_ID, SUBSCRIPTION_ID)

def callback(message: pubsub_v1.subscriber.message.Message) -> None:
    """Processes a received message."""
    print(f"Received message: {message.data.decode('utf-8')}")
    # Simulate some processing time
    time.sleep(0.5)
    message.ack()

def consume_messages():
    """Consumes messages from a Pub/Sub subscription."""
    streaming_pull_future = subscriber.subscribe(subscription_path, callback=callback)
    print(f"Listening for messages on {subscription_path}...")

    # Keep the main thread alive to allow the background thread to process messages.
    try:
        streaming_pull_future.result()
    except TimeoutError:
        streaming_pull_future.cancel()
        streaming_pull_future.result()

if __name__ == "__main__":
    if not PROJECT_ID:
        raise ValueError("The PROJECT_ID environment variable must be set.")

    print(f"Starting consumer for subscription: {subscription_path}")
    consume_messages()

