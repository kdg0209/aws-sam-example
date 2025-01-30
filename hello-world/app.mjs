import { v4 } from 'uuid';
import mysql from 'mysql2';
import dayjs from 'dayjs';
import chromium from '@sparticuz/chromium';
import { S3Client, ListBucketsCommand } from "@aws-sdk/client-s3";

export const lambdaHandler = async (event, context) => {
    const d = dayjs();
    
    const response = {
      statusCode: 200,
      body: JSON.stringify({
        message: 'example sam with lambda test !!!',
        uuid: v4(),
        day: d.format('YYYY-MM-DD HH:mm:ss')
      })
    };

    return response;
  };
