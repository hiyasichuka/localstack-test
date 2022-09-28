import { Context, APIGatewayProxyResult, APIGatewayProxyEvent, APIGatewayProxyHandler } from 'aws-lambda'
import pino from 'pino'

// Create a logger at bootstrap.
const logger = pino()

// Type definition for greeting message
interface GreetingMessasge {
  message: string
}

// Lambda handler
export const handler: APIGatewayProxyHandler = async (event: APIGatewayProxyEvent, context: Context): Promise<APIGatewayProxyResult> => {
  logger.info(`Event: ${JSON.stringify(event)}`)
  logger.info(`Context: ${JSON.stringify(context)}`)

  // Create a default greeting message
  let greetingMessage: GreetingMessasge = { message: 'Hello' }

  // Check if the request have a JSON request body
  // NOTE: It is recommended to use the `ajv` library to validate request parameters
  if (event.body != null && event.body !== '') {
    // Parse request body as greeting message
    greetingMessage = JSON.parse(event.body)
  }

  // Return the response.
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: greetingMessage.message + ', World!'
    })
  }
}
