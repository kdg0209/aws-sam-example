import { v5 as uuidv5 } from 'uuid';

export const lambdaHandler = async (event, context) => {

    const response = {
      statusCode: 200,
      body: JSON.stringify({
        message: 'hello lambda ?',
        uuid: uuidv5.URL
      })
    };

    return response;
  };
