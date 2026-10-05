import io
import json
import os
import uuid
from datetime import datetime, timezone

import boto3
from fastavro import parse_schema, schemaless_writer


AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")

KINESIS_STREAM_NAME = os.environ.get(
    "KINESIS_STREAM_NAME",
    "stadium-iot-events",
)

GLUE_REGISTRY_NAME = os.environ.get(
    "GLUE_REGISTRY_NAME",
    "stadium-iot",
)

GLUE_SCHEMA_NAME = os.environ.get(
    "GLUE_SCHEMA_NAME",
    "SensorEvent",
)


kinesis = boto3.client(
    "kinesis",
    region_name=AWS_REGION,
)

glue = boto3.client(
    "glue",
    region_name=AWS_REGION,
)


def load_schema():
    response = glue.get_schema_version(
        SchemaId={
            "SchemaName": GLUE_SCHEMA_NAME,
            "RegistryName": GLUE_REGISTRY_NAME,
        },
        SchemaVersionNumber={
            "LatestVersion": True,
        },
    )

    return (
        json.loads(response["SchemaDefinition"]),
        response["SchemaVersionId"],
    )


schema_definition, schema_version_id = load_schema()

AVRO_SCHEMA = parse_schema(schema_definition)


def convert_timestamp(timestamp_string):
    timestamp = datetime.fromisoformat(
        timestamp_string.replace("Z", "+00:00")
    )

    if timestamp.tzinfo is None:
        timestamp = timestamp.replace(tzinfo=timezone.utc)

    return int(timestamp.timestamp() * 1000)


def serialize_avro(event):
    event = event.copy()

    event["timestamp"] = convert_timestamp(
        event["timestamp"]
    )

    buffer = io.BytesIO()

    schemaless_writer(
        buffer,
        AVRO_SCHEMA,
        event,
    )

    return buffer.getvalue()


def add_schema_header(payload):
    schema_version_uuid = uuid.UUID(
        schema_version_id
    )

    header = (
        b"\x03"
        + b"\x00"
        + schema_version_uuid.bytes
    )

    return header + payload


def lambda_handler(event, context):

    print(
        f"Received event: {json.dumps(event)}"
    )

    avro_payload = serialize_avro(event)

    record = add_schema_header(
        avro_payload
    )

    response = kinesis.put_record(
        StreamName=KINESIS_STREAM_NAME,
        Data=record,
        PartitionKey=event["sensor_id"],
    )

    print(
        "Published to Kinesis: "
        f"shard={response['ShardId']} "
        f"sequence={response['SequenceNumber']}"
    )

    return {
        "statusCode": 200,
        "body": "Event published to Kinesis",
    }